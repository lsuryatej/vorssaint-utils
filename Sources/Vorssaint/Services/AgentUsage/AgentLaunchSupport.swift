// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// A session that ended, which its agent can pick up again. Holds no prompt,
/// reply or tool output.
struct AgentResumableSession: Equatable, Identifiable {
    /// The agent's session id.
    let id: String
    let provider: AgentProvider
    let project: String
    /// The folder the session ran in, from its log.
    let cwd: String
    let lastActivity: Date
    let cost: Double
}

/// A terminal a session can be started in.
enum AgentLaunchTerminal: String, CaseIterable, Identifiable {
    case terminal, iTerm2, ghostty, vscode

    var id: String { rawValue }

    var bundleID: String {
        switch self {
        case .terminal: return "com.apple.Terminal"
        case .iTerm2: return "com.googlecode.iterm2"
        case .ghostty: return "com.mitchellh.ghostty"
        case .vscode: return "com.microsoft.VSCode"
        }
    }

    var displayName: String {
        switch self {
        case .terminal: return "Terminal"
        case .iTerm2: return "iTerm2"
        case .ghostty: return "Ghostty"
        case .vscode: return "VS Code"
        }
    }

    init?(bundleIdentifier: String?) {
        guard let terminal = Self.allCases.first(where: { $0.bundleID == bundleIdentifier }) else { return nil }
        self = terminal
    }
}

/// What a launch does, decided before anything runs.
enum AgentLaunchPlan: Equatable {
    /// Terminal, iTerm2 and Ghostty type the command into a new shell, which
    /// has the person's own PATH.
    case script(bundleID: String, source: String)
    /// VS Code exposes no way to run a command in its terminal: the folder
    /// opens and the command waits on the clipboard.
    case openFolder(bundleID: String, folder: String, copying: String)
}

enum AgentLaunchSupport {
    /// The folder a session ran in: Claude writes it on most lines, Codex in
    /// the rollout's `session_meta`. Both come within the first lines.
    static func folder(head: Data) -> String? {
        for line in head.split(separator: 0x0A) where AgentLogParser.contains(Data(line), #""cwd":""#) {
            guard let json = (try? JSONSerialization.jsonObject(with: Data(line))) as? [String: Any] else { continue }
            let cwd = json["cwd"] as? String ?? (json["payload"] as? [String: Any])?["cwd"] as? String
            if let cwd, cwd.hasPrefix("/") { return cwd }
        }
        return nil
    }

    private static func quote(_ value: String) -> String { UpdateInstallerSupport.shellSingleQuoted(value) }

    private static func tool(_ provider: AgentProvider) -> String? {
        switch provider {
        case .claude: return "claude"
        case .codex: return "codex"
        // ponytail: OpenCode keeps its sessions in a database; add `opencode --session` once tried.
        case .opencode, .copilot: return nil
        }
    }

    /// `cd '<cwd>' && claude --resume '<id>'`; Codex resumes from the folder too.
    static func resumeCommand(_ session: AgentResumableSession) -> String? {
        guard let tool = tool(session.provider) else { return nil }
        let resume = session.provider == .claude ? "--resume" : "resume"
        return "cd \(quote(session.cwd)) && \(tool) \(resume) \(quote(session.id))"
    }

    /// `cd '<cwd>' && claude -- '<prompt>'`. The field is one line, and a
    /// pasted line break would send the command early. Quoting keeps the
    /// shell out of the prompt but not the tool: `--` ends its options, so a
    /// prompt such as `--help` or `-p x` is sent as text, never read as a flag.
    static func startCommand(provider: AgentProvider, cwd: String, prompt: String) -> String? {
        guard let tool = tool(provider) else { return nil }
        let line = prompt.components(separatedBy: .newlines).joined(separator: " ").trimmingCharacters(in: .whitespaces)
        return "cd \(quote(cwd)) && \(tool)" + (line.isEmpty ? "" : " -- \(quote(line))")
    }

    /// Menu titles for launch folders: the project's name, unless another
    /// folder shares it, as a repository and its Claude worktrees do; those
    /// show their path from the home folder so each entry says where it runs.
    static func folderTitles(_ paths: [String], home: String = NSHomeDirectory()) -> [String: String] {
        let names = Dictionary(paths.map { ($0, AgentLogParser.projectName($0)) }, uniquingKeysWith: { first, _ in first })
        let counts = names.values.reduce(into: [String: Int]()) { $0[$1, default: 0] += 1 }
        return names.reduce(into: [String: String]()) { titles, entry in
            let (path, name) = entry
            guard counts[name, default: 0] > 1 else { titles[path] = name; return }
            titles[path] = path.hasPrefix(home + "/") ? "~" + path.dropFirst(home.count) : path
        }
    }

    /// The terminal chosen in Settings while it is installed, else the one the
    /// newest session runs in, else Terminal.
    static func destination(setting: String, detected: AgentLaunchTerminal?,
                            installed: (AgentLaunchTerminal) -> Bool) -> AgentLaunchTerminal {
        if let chosen = AgentLaunchTerminal(rawValue: setting), installed(chosen) { return chosen }
        return detected ?? .terminal
    }

    static func plan(_ command: String, cwd: String, in terminal: AgentLaunchTerminal) -> AgentLaunchPlan {
        let text = AppleScriptRunner.literal(command)
        switch terminal {
        case .terminal:
            // ponytail: `do script` opens a window; a tab needs System Events keystrokes.
            return .script(bundleID: terminal.bundleID, source: """
            tell application "Terminal"
                activate
                do script \(text)
            end tell
            """)
        case .iTerm2:
            return .script(bundleID: terminal.bundleID, source: """
            tell application "iTerm2"
                activate
                if (count of windows) is 0 then
                    create window with default profile
                else
                    tell current window to create tab with default profile
                end if
                tell current session of current window to write text \(text)
            end tell
            """)
        case .ghostty:
            return .script(bundleID: terminal.bundleID, source: """
            tell application "Ghostty"
                set config to new surface configuration
                set initial working directory of config to \(AppleScriptRunner.literal(cwd))
                set initial input of config to \(text) & linefeed
                if (count of windows) is 0 then
                    new window with configuration config
                else
                    new tab in front window with configuration config
                end if
                activate
            end tell
            """)
        case .vscode:
            return .openFolder(bundleID: terminal.bundleID, folder: cwd, copying: command)
        }
    }
}
