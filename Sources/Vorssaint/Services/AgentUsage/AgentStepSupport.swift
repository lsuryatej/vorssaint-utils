// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// What a step does, by the tool the agent called.
enum AgentStepKind: String, Equatable {
    case read, edit, write, run, search, web, task, other

    var symbol: String {
        switch self {
        case .read: return "doc.text"
        case .edit: return "pencil"
        case .write: return "doc.badge.plus"
        case .run: return "terminal"
        case .search: return "magnifyingglass"
        case .web: return "globe"
        case .task: return "person.2"
        case .other: return "wrench.and.screwdriver"
        }
    }
}

/// One line of an edit's diff.
struct AgentDiffLine: Equatable {
    enum Kind: Equatable { case same, added, removed, gap }
    let kind: Kind
    let text: String
}

/// One tool call of a session, reduced to what the island shows: the tool,
/// the file or command it acts on, and for an edit its changed lines. Built
/// only while Steps is on, held in memory and never saved.
struct AgentStep: Equatable, Identifiable {
    /// The tool call's own identifier, which repeats when a log is read again.
    let id: String
    let date: Date
    let kind: AgentStepKind
    /// A file name, a command's first line or a search, at most `targetLimit`.
    let target: String
    /// The folder or full path behind the target, for a tooltip.
    let detail: String
    var added = 0
    var removed = 0
    var diff: [AgentDiffLine] = []
}

enum AgentStepSupport {
    static let targetLimit = 80
    /// Steps kept per session; the card shows the newest few.
    static let kept = 12
    /// An edit's diff keeps this many lines, gaps included.
    static let diffLimit = 80
    /// Unchanged lines kept around each change.
    static let context = 2
    /// Larger edits are counted, not diffed: the table grows with both sides.
    static let diffCells = 250_000

    /// A Claude Code `tool_use` block as a step; nil for blocks that are not
    /// one or that only plan, like the to-do list.
    static func claudeStep(_ block: [String: Any], date: Date) -> AgentStep? {
        guard block["type"] as? String == "tool_use", let id = block["id"] as? String, !id.isEmpty,
              let name = block["name"] as? String else { return nil }
        let input = block["input"] as? [String: Any] ?? [:]
        let path = input["file_path"] as? String ?? input["notebook_path"] as? String ?? ""
        switch name {
        case "Read":
            return file(id, date, .read, path)
        case "Edit":
            var step = file(id, date, .edit, path)
            apply(edits: [(input["old_string"] as? String ?? "", input["new_string"] as? String ?? "")], to: &step)
            return step
        case "MultiEdit":
            var step = file(id, date, .edit, path)
            let edits = (input["edits"] as? [[String: Any]] ?? []).map { edit -> (old: String, new: String) in
                (edit["old_string"] as? String ?? "", edit["new_string"] as? String ?? "")
            }
            apply(edits: edits, to: &step)
            return step
        case "Write":
            var step = file(id, date, .write, path)
            apply(edits: [("", input["content"] as? String ?? "")], to: &step)
            return step
        case "NotebookEdit":
            var step = file(id, date, .edit, path)
            apply(edits: [("", input["new_source"] as? String ?? "")], to: &step)
            return step
        case "Bash":
            let command = input["command"] as? String ?? ""
            let description = input["description"] as? String ?? ""
            return AgentStep(id: id, date: date, kind: .run, target: line(command), detail: line(description))
        case "Grep":
            return AgentStep(id: id, date: date, kind: .search, target: line(input["pattern"] as? String ?? ""),
                             detail: input["path"] as? String ?? "")
        case "Glob":
            return AgentStep(id: id, date: date, kind: .search, target: line(input["pattern"] as? String ?? ""),
                             detail: input["path"] as? String ?? "")
        case "WebFetch":
            let url = input["url"] as? String ?? ""
            return AgentStep(id: id, date: date, kind: .web, target: URL(string: url)?.host ?? line(url), detail: url)
        case "WebSearch":
            return AgentStep(id: id, date: date, kind: .web, target: line(input["query"] as? String ?? ""), detail: "")
        case "Task", "Agent":
            return AgentStep(id: id, date: date, kind: .task, target: line(input["description"] as? String ?? name),
                             detail: input["subagent_type"] as? String ?? "")
        case "TodoWrite", "ExitPlanMode", "AskUserQuestion":
            return nil
        default:
            // MCP tools read `mcp__server__tool`: the tool's own name is enough.
            let short = name.hasPrefix("mcp__") ? name.components(separatedBy: "__").last ?? name : name
            return AgentStep(id: id, date: date, kind: .other, target: line(short), detail: name)
        }
    }

    private static func file(_ id: String, _ date: Date, _ kind: AgentStepKind, _ path: String) -> AgentStep {
        AgentStep(id: id, date: date, kind: kind, target: line((path as NSString).lastPathComponent),
                  detail: (path as NSString).deletingLastPathComponent)
    }

    /// One line, trimmed and cut, so a command or pattern never wraps.
    static func line(_ text: String) -> String {
        let first = text.split(whereSeparator: \.isNewline).first.map(String.init) ?? ""
        let trimmed = first.trimmingCharacters(in: .whitespaces)
        guard trimmed.count > targetLimit else { return trimmed }
        return String(trimmed.prefix(targetLimit - 1)) + "…"
    }

    private static func apply(edits: [(old: String, new: String)], to step: inout AgentStep) {
        for (index, edit) in edits.enumerated() {
            let result = diff(old: edit.old, new: edit.new)
            step.added += result.added
            step.removed += result.removed
            if index > 0, !result.lines.isEmpty, !step.diff.isEmpty { step.diff.append(AgentDiffLine(kind: .gap, text: "")) }
            step.diff.append(contentsOf: result.lines)
        }
        if step.diff.count > diffLimit {
            step.diff = Array(step.diff.prefix(diffLimit - 1)) + [AgentDiffLine(kind: .gap, text: "")]
        }
    }

    private static func lines(_ text: String) -> [String] {
        guard !text.isEmpty else { return [] }
        var lines = text.components(separatedBy: "\n")
        if lines.last == "" { lines.removeLast() }
        return lines
    }

    /// A line diff by longest common subsequence, with `context` unchanged
    /// lines around each change and a gap where more were left out. Past
    /// `diffCells` the lines are only counted, every old one as removed.
    static func diff(old: String, new: String) -> (lines: [AgentDiffLine], added: Int, removed: Int) {
        let a = lines(old), b = lines(new)
        guard a.count * b.count <= diffCells else { return ([], b.count, a.count) }
        // Common prefix and suffix need no table.
        var prefix = 0
        while prefix < a.count, prefix < b.count, a[prefix] == b[prefix] { prefix += 1 }
        var suffix = 0
        while suffix < a.count - prefix, suffix < b.count - prefix,
              a[a.count - 1 - suffix] == b[b.count - 1 - suffix] { suffix += 1 }
        let x = Array(a[prefix..<(a.count - suffix)]), y = Array(b[prefix..<(b.count - suffix)])
        var table = [[Int]](repeating: [Int](repeating: 0, count: y.count + 1), count: x.count + 1)
        if !x.isEmpty, !y.isEmpty {
            for i in stride(from: x.count - 1, through: 0, by: -1) {
                for j in stride(from: y.count - 1, through: 0, by: -1) {
                    table[i][j] = x[i] == y[j] ? table[i + 1][j + 1] + 1 : max(table[i + 1][j], table[i][j + 1])
                }
            }
        }
        var middle: [AgentDiffLine] = []
        var i = 0, j = 0
        while i < x.count || j < y.count {
            // On a tie the old line goes first, as a diff reads.
            if i < x.count, j < y.count, x[i] == y[j] {
                middle.append(AgentDiffLine(kind: .same, text: x[i])); i += 1; j += 1
            } else if i < x.count, j == y.count || table[i + 1][j] >= table[i][j + 1] {
                middle.append(AgentDiffLine(kind: .removed, text: x[i])); i += 1
            } else {
                middle.append(AgentDiffLine(kind: .added, text: y[j])); j += 1
            }
        }
        let all = a[..<prefix].map { AgentDiffLine(kind: .same, text: $0) } + middle
            + a[(a.count - suffix)...].map { AgentDiffLine(kind: .same, text: $0) }
        let added = all.filter { $0.kind == .added }.count, removed = all.filter { $0.kind == .removed }.count
        return (trimmed(all), added, removed)
    }

    /// Keeps changed lines and `context` around them; a run left out becomes one gap.
    private static func trimmed(_ lines: [AgentDiffLine]) -> [AgentDiffLine] {
        let changed = lines.indices.filter { lines[$0].kind != .same }
        guard !changed.isEmpty else { return [] }
        var keep = Set<Int>()
        for index in changed { keep.formUnion(max(0, index - context)...min(lines.count - 1, index + context)) }
        var result: [AgentDiffLine] = []
        var skipped = false
        for index in lines.indices {
            if keep.contains(index) {
                if skipped, !result.isEmpty { result.append(AgentDiffLine(kind: .gap, text: "")) }
                skipped = false
                result.append(lines[index])
            } else {
                skipped = true
            }
        }
        return result
    }

    /// `+12 −3`, or nil for a step that changed nothing.
    static func counts(_ step: AgentStep) -> String? {
        guard step.added > 0 || step.removed > 0 else { return nil }
        return [step.added > 0 ? "+\(step.added)" : nil, step.removed > 0 ? "−\(step.removed)" : nil]
            .compactMap { $0 }.joined(separator: " ")
    }

    /// Keeps the newest `kept` steps, replacing one read again by its id.
    static func merge(_ step: AgentStep, into steps: [AgentStep]) -> [AgentStep] {
        var steps = steps.filter { $0.id != step.id }
        steps.append(step)
        steps.sort { $0.date < $1.date }
        return Array(steps.suffix(kept))
    }
}
