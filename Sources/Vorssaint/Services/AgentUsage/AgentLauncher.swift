// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit

/// Starts an agent's command-line tool in the terminal the person chose.
enum AgentLauncher {
    enum Outcome { case started, copied, failed }

    /// Main thread. `board` gives the terminal of the newest session when
    /// Settings leaves the choice to the app. `finish` runs on main once the
    /// launch is known to have worked or failed: a script waits on the
    /// terminal, and on a consent prompt the first time.
    static func run(_ command: String, cwd: String, board: [AgentSessionRow], finish: @escaping (Outcome) -> Void) {
        var directory: ObjCBool = false
        guard NotchAgentSupport.isEnabled(), FileManager.default.fileExists(atPath: cwd, isDirectory: &directory),
              directory.boolValue else { return finish(.failed) }
        let terminal = AgentLaunchSupport.destination(setting: NotchAgentSupport.openIn(), detected: detected(board),
                                                      installed: installed)
        switch AgentLaunchSupport.plan(command, cwd: cwd, in: terminal) {
        case .script(_, let source):
            DispatchQueue.global(qos: .userInitiated).async {
                let result = AppleScriptRunner.runDetailed(source)
                DispatchQueue.main.async {
                    // The island folds only once the terminal has the command,
                    // so a failure stays on the card that asked.
                    guard result.ok else {
                        if result.errorNumber == -1743 || result.errorNumber == -1744 {
                            Permissions.shared.openAutomationSettings()
                        }
                        return finish(.failed)
                    }
                    NotchService.shared.collapse()
                    finish(.started)
                }
            }
        case .openFolder(let bundleID, let folder, let command):
            guard let app = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else { return finish(.failed) }
            // The general pasteboard is only touched on its own lane, which
            // the clipboard history and transient pastes share.
            GeneralPasteboardAccess.shared.async({ () -> Bool in
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                return pasteboard.setString(command, forType: .string)
            }, then: { copied in
                guard copied else { return finish(.failed) }
                NSWorkspace.shared.open([URL(fileURLWithPath: folder, isDirectory: true)], withApplicationAt: app,
                                        configuration: NSWorkspace.OpenConfiguration())
                finish(.copied)
            })
        }
    }

    static func installed(_ terminal: AgentLaunchTerminal) -> Bool {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: terminal.bundleID) != nil
    }

    /// The app that owns the newest Claude session with a process.
    private static func detected(_ board: [AgentSessionRow]) -> AgentLaunchTerminal? {
        board.filter { $0.pid != nil }.sorted { $0.since > $1.since }.lazy
            .compactMap { ResponsibleProcess.regularAppOwner(of: $0.pid!) }
            .compactMap { AgentLaunchTerminal(bundleIdentifier: $0.bundleIdentifier) }.first
    }
}
