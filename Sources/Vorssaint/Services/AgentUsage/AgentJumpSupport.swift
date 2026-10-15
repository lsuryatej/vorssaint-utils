// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// The terminal a session runs in, by how it can be brought forward.
enum AgentTerminalKind: Equatable {
    /// Scriptable by tty: the exact tab is selected.
    case terminal, iTerm2
    /// Scriptable by working folder: the one terminal in it is focused.
    case ghostty
    /// The window whose title names the session's folder comes forward;
    /// VS Code exposes nothing that tells its terminal tabs apart.
    case vscode
    case other

    init(bundleIdentifier: String?) {
        switch bundleIdentifier {
        case "com.apple.Terminal": self = .terminal
        case "com.googlecode.iterm2": self = .iTerm2
        case "com.mitchellh.ghostty": self = .ghostty
        case "com.microsoft.VSCode", "com.microsoft.VSCodeInsiders", "com.todesktop.230313mzl4w4u92": self = .vscode
        default: self = .other
        }
    }
}

/// A running `codex` process, as the kernel reports it.
struct AgentSessionProcess: Equatable {
    let pid: Int32
    let cwd: String?
    let started: Date
    /// The rollouts it holds open: Codex keeps its own for the whole session.
    var rollouts: Set<String> = []
}

enum AgentJumpSupport {
    /// The folder and start time of a Codex rollout, from its first line.
    static func codexMeta(firstLine: Data) -> (cwd: String, started: Date)? {
        guard let json = (try? JSONSerialization.jsonObject(with: firstLine)) as? [String: Any],
              json["type"] as? String == "session_meta",
              let cwd = (json["payload"] as? [String: Any])?["cwd"] as? String, !cwd.isEmpty,
              let started = AgentLogParser.timestamp(json["timestamp"])
        else { return nil }
        return (cwd, started)
    }

    /// Codex keeps no pid, but a running session holds its rollout open, so
    /// only the one process holding it owns it. A folder and a start time
    /// prove nothing: an ended session would pick another codex still running
    /// there, and a resumed one an unrelated process that started earlier.
    /// Nil when no process, or more than one, holds the rollout.
    static func codexProcess(rollout: String, among processes: [AgentSessionProcess]) -> AgentSessionProcess? {
        let path = (rollout as NSString).standardizingPath
        let owners = processes.filter { $0.rollouts.contains(path) }
        return owners.count == 1 ? owners[0] : nil
    }

    /// `devname` output such as `ttys002`; anything else never reaches a script.
    static func isTTYName(_ name: String) -> Bool {
        name.range(of: #"^tty[a-z]?[0-9A-Za-z]{1,8}$"#, options: .regularExpression) != nil
    }

    /// The VS Code window for a folder: its title (`file — folder — VS Code`
    /// by default) names the workspace root, which is the folder or one of its
    /// parents, so the deepest folder named wins. A title names the folder,
    /// not its path: when two windows name the deepest match (two workspaces
    /// called `repo`), neither is known to hold the session and nil leaves
    /// the choice to the app.
    static func vsCodeWindow(titles: [String], cwd: String) -> Int? {
        let segments = titles.map { Set($0.components(separatedBy: " — ").map { $0.trimmingCharacters(in: .whitespaces) }) }
        var folder = (cwd as NSString).standardizingPath
        while folder != "/", folder != NSHomeDirectory(), !folder.isEmpty {
            let name = (folder as NSString).lastPathComponent
            let matches = segments.indices.filter { segments[$0].contains(name) }
            if matches.count == 1 { return matches[0] }
            if matches.count > 1 { return nil }
            folder = (folder as NSString).deletingLastPathComponent
        }
        return nil
    }

    /// Every script answers "yes" when it found the session, "no" otherwise.
    static func script(for kind: AgentTerminalKind, tty: String?, cwd: String?) -> String? {
        switch kind {
        case .terminal:
            guard let tty, isTTYName(tty) else { return nil }
            return """
            tell application "Terminal"
                repeat with w in windows
                    repeat with t in tabs of w
                        if tty of t is "/dev/\(tty)" then
                            set selected of t to true
                            set frontmost of w to true
                            activate
                            return "yes"
                        end if
                    end repeat
                end repeat
                return "no"
            end tell
            """
        case .iTerm2:
            guard let tty, isTTYName(tty) else { return nil }
            return """
            tell application "iTerm2"
                repeat with w in windows
                    repeat with t in tabs of w
                        repeat with s in sessions of t
                            if tty of s is "/dev/\(tty)" then
                                select s
                                select t
                                select w
                                activate
                                return "yes"
                            end if
                        end repeat
                    end repeat
                end repeat
                return "no"
            end tell
            """
        case .ghostty:
            // Ghostty exposes no tty, so only a folder no other terminal shares
            // names the session; otherwise the app comes forward as it is.
            guard let cwd, !cwd.isEmpty else { return nil }
            return """
            tell application "Ghostty"
                set found to (terminals whose working directory is \(AppleScriptRunner.literal(cwd)))
                if (count of found) is not 1 then return "no"
                focus item 1 of found
                activate
                return "yes"
            end tell
            """
        case .vscode, .other:
            return nil
        }
    }
}
