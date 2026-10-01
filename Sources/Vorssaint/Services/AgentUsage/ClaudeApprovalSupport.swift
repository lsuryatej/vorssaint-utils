// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// One Claude Code PermissionRequest, reduced to what the notch card shows and
/// what the reply and the transcript watch need.
struct ClaudeApprovalRequest: Equatable {
    /// Assigned by the service per connection, so an answer reaches the request
    /// the card showed and never one that replaced it a moment later.
    var id = 0
    let cwd: String
    let toolName: String
    let toolInput: NSDictionary
    let summary: String
    let transcriptPath: String?
    /// The `addRules` suggestions only. Claude Code also suggests session-wide
    /// updates such as switching to accept-edits mode, which is broader than
    /// what "Always" promises, so those are never sent.
    let alwaysRules: NSArray?

    var canAlways: Bool { alwaysRules != nil }
    var project: String { AgentLogParser.projectName(cwd) }
}

enum ClaudeApprovalDecision { case allow, deny, always }

enum ClaudeHookStatus: Equatable { case notInstalled, installed, otherCopy, unreadable }

struct ClaudeSettingsDiffLine: Equatable {
    enum Kind { case same, added, removed }
    let kind: Kind
    let text: String
}

enum ClaudeApprovalSupport {
    /// Claude Code waits up to the hook timeout (120 s) and the relay up to
    /// 115 s; releasing first keeps Claude Code's own prompt in charge.
    static let pendingSeconds: TimeInterval = 110
    static let hookTimeout = 120
    static let denyMessage = "Denied in Vorssaint"
    /// `sun_path` holds 104 bytes including the terminator.
    static let socketPathLimit = 103

    static func isEnabled(in defaults: UserDefaults = .standard) -> Bool {
        NotchAgentSupport.isEnabled(in: defaults)
            && AppFeature.notchAgentApprovals.isAvailable(in: defaults)
            && defaults.bool(forKey: DefaultsKey.notchAgentApprovalsEnabled)
    }

    static func socketPath(container: URL) -> String? {
        let path = container.appendingPathComponent("claude.sock").path
        return path.utf8.count <= socketPathLimit ? path : nil
    }

    static var settingsURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude/settings.json")
    }

    // MARK: Payload and reply

    static func parseRequest(_ data: Data) -> ClaudeApprovalRequest? {
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              object["hook_event_name"] as? String == "PermissionRequest",
              let tool = object["tool_name"] as? String, !tool.isEmpty
        else { return nil }
        let input = object["tool_input"] as? [String: Any] ?? [:]
        let rules = (object["permission_suggestions"] as? [Any] ?? []).filter {
            guard let update = $0 as? [String: Any] else { return false }
            return update["type"] as? String == "addRules" && !(update["rules"] as? [Any] ?? []).isEmpty
        }
        return ClaudeApprovalRequest(
            cwd: object["cwd"] as? String ?? "",
            toolName: tool,
            toolInput: input as NSDictionary,
            summary: summary(tool: tool, input: input),
            transcriptPath: object["transcript_path"] as? String,
            alwaysRules: rules.isEmpty ? nil : rules as NSArray)
    }

    static func summary(tool: String, input: [String: Any]) -> String {
        if let command = input["command"] as? String { return command }
        if let path = input["file_path"] as? String ?? input["notebook_path"] as? String { return path }
        guard JSONSerialization.isValidJSONObject(input),
              let data = try? JSONSerialization.data(withJSONObject: input, options: [.sortedKeys, .withoutEscapingSlashes])
        else { return tool }
        return String(decoding: data, as: UTF8.self)
    }

    static func reply(_ decision: ClaudeApprovalDecision, for request: ClaudeApprovalRequest) -> Data {
        var verdict: [String: Any]
        switch decision {
        case .allow: verdict = ["behavior": "allow"]
        case .deny: verdict = ["behavior": "deny", "message": denyMessage]
        case .always:
            verdict = ["behavior": "allow"]
            if let rules = request.alwaysRules { verdict["updatedPermissions"] = rules }
        }
        let output: [String: Any] = ["hookSpecificOutput": [
            "hookEventName": "PermissionRequest", "decision": verdict]]
        return (try? JSONSerialization.data(withJSONObject: output, options: [.sortedKeys])) ?? Data()
    }

    // MARK: Transcript

    /// Claude Code shows its own prompt alongside the hook and keeps the hook
    /// running after the user answers there, so the transcript is the only
    /// sign the request is settled. `toolUseID` follows the latest tool_use
    /// matching the request; its tool_result settles it. `counting` is false
    /// for lines written before the request arrived, which only find the id.
    static func scanTranscript(_ lines: [Substring], for request: ClaudeApprovalRequest,
                               toolUseID: inout String?, counting: Bool) -> Bool {
        for line in lines where line.contains("tool_") {
            guard let object = try? JSONSerialization.jsonObject(with: Data(line.utf8)) as? [String: Any],
                  let content = (object["message"] as? [String: Any])?["content"] as? [[String: Any]]
            else { continue }
            for block in content {
                switch block["type"] as? String {
                case "tool_use":
                    if block["name"] as? String == request.toolName,
                       (block["input"] as? NSDictionary ?? [:]) == request.toolInput {
                        toolUseID = block["id"] as? String
                    }
                case "tool_result":
                    guard let id = toolUseID, block["tool_use_id"] as? String == id else { continue }
                    if counting { return true }
                    toolUseID = nil
                default: continue
                }
            }
        }
        return false
    }

    // MARK: settings.json

    static func hookCommand(executable: String, socket: String) -> String {
        "\(shellQuoted(executable)) \(ClaudeApprovalRelay.argument) \(shellQuoted(socket))"
    }

    static func shellQuoted(_ text: String) -> String {
        "'" + text.replacingOccurrences(of: "'", with: #"'\''"#) + "'"
    }

    static func isVorssaintHook(_ command: String) -> Bool {
        command.contains(ClaudeApprovalRelay.argument)
    }

    private static func permissionCommands(in settings: [String: Any]) -> [String] {
        let groups = (settings["hooks"] as? [String: Any])?["PermissionRequest"] as? [[String: Any]] ?? []
        return groups.flatMap { ($0["hooks"] as? [[String: Any]] ?? []).compactMap { $0["command"] as? String } }
    }

    static func installedCommand(in settings: [String: Any]) -> String? {
        permissionCommands(in: settings).first(where: isVorssaintHook)
    }

    static func foreignPermissionHooks(in settings: [String: Any]) -> [String] {
        permissionCommands(in: settings).filter { !isVorssaintHook($0) }
    }

    /// nil for a missing file, which installs into an empty object.
    static func parseSettings(_ data: Data?) -> [String: Any]? {
        guard let data, !data.allSatisfy({ $0 == 0x20 || $0 == 0x0A || $0 == 0x09 || $0 == 0x0D })
        else { return [:] }
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }

    static func status(of data: Data?, command: String) -> ClaudeHookStatus {
        guard let settings = parseSettings(data) else { return .unreadable }
        switch installedCommand(in: settings) {
        case nil: return .notInstalled
        case command: return .installed
        default: return .otherCopy
        }
    }

    /// Any earlier Vorssaint entry (another build, a moved app) is removed
    /// first, so installing again is also the migration.
    static func installing(_ settings: [String: Any], command: String) -> [String: Any] {
        var settings = uninstalling(settings)
        var hooks = settings["hooks"] as? [String: Any] ?? [:]
        var groups = hooks["PermissionRequest"] as? [Any] ?? []
        groups.append(["hooks": [["type": "command", "command": command, "timeout": hookTimeout]]])
        hooks["PermissionRequest"] = groups
        settings["hooks"] = hooks
        return settings
    }

    static func uninstalling(_ settings: [String: Any]) -> [String: Any] {
        guard var hooks = settings["hooks"] as? [String: Any],
              let groups = hooks["PermissionRequest"] as? [Any]
        else { return settings }
        let kept: [Any] = groups.compactMap { item in
            guard var group = item as? [String: Any], let entries = group["hooks"] as? [Any] else { return item }
            let others = entries.filter { !isVorssaintHook(($0 as? [String: Any])?["command"] as? String ?? "") }
            guard others.count != entries.count else { return item }
            guard !others.isEmpty else { return nil }
            group["hooks"] = others
            return group
        }
        var settings = settings
        hooks["PermissionRequest"] = kept.isEmpty ? nil : kept
        settings["hooks"] = hooks.isEmpty ? nil : hooks
        return settings
    }

    static func render(_ settings: [String: Any]) -> Data {
        var data = (try? JSONSerialization.data(
            withJSONObject: settings, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])) ?? Data("{}".utf8)
        data.append(0x0A)
        return data
    }

    /// ponytail: O(n·m) line LCS, fine for a settings file; Myers if it ever isn't.
    static func diff(_ old: String, _ new: String) -> [ClaudeSettingsDiffLine] {
        let a = old.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let b = new.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var lengths = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        for i in stride(from: a.count - 1, through: 0, by: -1) {
            for j in stride(from: b.count - 1, through: 0, by: -1) {
                lengths[i][j] = a[i] == b[j] ? lengths[i + 1][j + 1] + 1 : max(lengths[i + 1][j], lengths[i][j + 1])
            }
        }
        var lines: [ClaudeSettingsDiffLine] = []
        var i = 0, j = 0
        while i < a.count || j < b.count {
            if i < a.count, j < b.count, a[i] == b[j] {
                lines.append(.init(kind: .same, text: a[i])); i += 1; j += 1
            } else if j < b.count, i == a.count || lengths[i][j + 1] >= lengths[i + 1][j] {
                lines.append(.init(kind: .added, text: b[j])); j += 1
            } else {
                lines.append(.init(kind: .removed, text: a[i])); i += 1
            }
        }
        return lines
    }

    static func backupName(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return "settings.json.bak-" + formatter.string(from: date)
    }
}
