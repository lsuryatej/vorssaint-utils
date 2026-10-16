// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Steps: each tool call a session makes, read from its log while Steps is on.
enum AgentStepTests {
    private static let at = Date(timeIntervalSince1970: 1_790_000_000)

    private static func block(_ name: String, _ input: [String: Any], id: String = "toolu_1") -> [String: Any] {
        ["type": "tool_use", "id": id, "name": name, "input": input]
    }

    static func run(_ suite: TestSuite) {
        steps(suite)
        diffs(suite)
        parsing(suite)
        store(suite)
    }

    private static func steps(_ suite: TestSuite) {
        let read = AgentStepSupport.claudeStep(block("Read", ["file_path": "/code/app/Sources/main.swift"]), date: at)
        suite.expect(read?.kind == .read && read?.target == "main.swift" && read?.detail == "/code/app/Sources",
                     "a read names its file, with the folder kept for the tooltip")
        let edit = AgentStepSupport.claudeStep(block("Edit", ["file_path": "/a/b.swift", "old_string": "let x = 1\nlet y = 2",
                                                               "new_string": "let x = 1\nlet y = 3\nlet z = 4"]), date: at)
        suite.expect(edit?.kind == .edit && edit?.added == 2 && edit?.removed == 1,
                     "an edit counts the lines it adds and removes")
        let multi = AgentStepSupport.claudeStep(block("MultiEdit", ["file_path": "/a/b.swift", "edits": [
            ["old_string": "a", "new_string": "b"], ["old_string": "c", "new_string": "d"]]]), date: at)
        suite.expect(multi?.added == 2 && multi?.removed == 2 && multi?.diff.contains { $0.kind == .gap } == true,
                     "a multi-edit sums its edits and separates them with a gap")
        let write = AgentStepSupport.claudeStep(block("Write", ["file_path": "/a/new.md", "content": "one\ntwo\n"]), date: at)
        suite.expect(write?.kind == .write && write?.added == 2 && write?.removed == 0, "a new file is all added lines")
        let bash = AgentStepSupport.claudeStep(block("Bash", ["command": "swift build \\\n  -c release", "description": "Build"]),
                                               date: at)
        suite.expect(bash?.kind == .run && bash?.target == "swift build \\" && bash?.detail == "Build",
                     "a command shows its first line")
        let long = AgentStepSupport.claudeStep(block("Bash", ["command": String(repeating: "x", count: 200)]), date: at)
        suite.expect(long?.target.count == AgentStepSupport.targetLimit && long?.target.hasSuffix("…") == true,
                     "a long command is cut to the limit")
        let fetch = AgentStepSupport.claudeStep(block("WebFetch", ["url": "https://docs.swift.org/x?y=1"]), date: at)
        suite.expect(fetch?.kind == .web && fetch?.target == "docs.swift.org", "a fetch names its host")
        let mcp = AgentStepSupport.claudeStep(block("mcp__github__create_issue", [:]), date: at)
        suite.expect(mcp?.kind == .other && mcp?.target == "create_issue" && mcp?.detail == "mcp__github__create_issue",
                     "an MCP tool shows its own name, the server's kept for the tooltip")
        suite.expect(AgentStepSupport.claudeStep(block("TodoWrite", ["todos": []]), date: at) == nil
                     && AgentStepSupport.claudeStep(["type": "text", "text": "hi"], date: at) == nil
                     && AgentStepSupport.claudeStep(block("Read", [:], id: ""), date: at) == nil,
                     "planning tools, text and calls without an id are not steps")

        let first = AgentStep(id: "1", date: at, kind: .read, target: "a", detail: "")
        let again = AgentStep(id: "1", date: at, kind: .read, target: "a2", detail: "")
        var kept: [AgentStep] = []
        for index in 0..<20 {
            kept = AgentStepSupport.merge(AgentStep(id: "s\(index)", date: at.addingTimeInterval(Double(index)), kind: .run,
                                                    target: "\(index)", detail: ""), into: kept)
        }
        suite.expect(kept.count == AgentStepSupport.kept && kept.last?.target == "19",
                     "a session keeps its newest steps only")
        suite.expect(AgentStepSupport.merge(again, into: [first]).map(\.target) == ["a2"],
                     "a step read again replaces itself")
    }

    private static func diffs(_ suite: TestSuite) {
        let old = (1...20).map { "line \($0)" }.joined(separator: "\n")
        let new = old.replacingOccurrences(of: "line 10", with: "line ten")
        let result = AgentStepSupport.diff(old: old, new: new)
        suite.expect(result.added == 1 && result.removed == 1, "one changed line is one removed and one added")
        suite.expect(result.lines.map(\.kind) == [.same, .same, .removed, .added, .same, .same],
                     "a change keeps two lines of context on each side")
        let twoChanges = AgentStepSupport.diff(old: old, new: new.replacingOccurrences(of: "line 1\n", with: "first\n"))
        suite.expect(twoChanges.lines.contains { $0.kind == .gap }, "context far apart is joined by a gap")
        suite.expect(AgentStepSupport.diff(old: "same", new: "same").lines.isEmpty, "nothing changed, no lines")
        let big = (0..<600).map { "a\($0)" }.joined(separator: "\n")
        let bigNew = (0..<600).map { "b\($0)" }.joined(separator: "\n")
        let counted = AgentStepSupport.diff(old: big, new: bigNew)
        suite.expect(counted.lines.isEmpty && counted.added == 600 && counted.removed == 600,
                     "a very large edit is counted, not diffed")
        let edit = AgentStepSupport.claudeStep(block("Write", ["file_path": "/a", "content": (0..<300).map { "\($0)" }
            .joined(separator: "\n")]), date: at)
        suite.expect(edit?.diff.count == AgentStepSupport.diffLimit && edit?.diff.last?.kind == .gap,
                     "a long diff is cut, ending in a gap")
        suite.expect(AgentStepSupport.counts(AgentStep(id: "x", date: at, kind: .edit, target: "", detail: "",
                                                       added: 3, removed: 1)) == "+3 −1",
                     "counts read +added −removed")
    }

    private static func parsing(_ suite: TestSuite) {
        let now = Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let stamp = formatter.string(from: now)
        let line = Data(#"""
        {"type":"assistant","timestamp":"\#(stamp)","sessionId":"s1","cwd":"/code/app","isSidechain":false,\#
        "message":{"id":"m1","model":"claude-opus-5-5","stop_reason":null,"content":[\#
        {"type":"tool_use","id":"toolu_9","name":"Edit","input":{"file_path":"/code/app/a.swift","old_string":"a","new_string":"b"}}]}}
        """#.utf8)
        AgentLogParser.readsSteps = false
        var state = AgentLogState()
        suite.expect(!AgentLogParser.parseClaude(line, state: &state, now: now).contains { if case .step = $0 { true } else { false } },
                     "with Steps off, tool calls stay counters only")
        AgentLogParser.readsSteps = true
        defer { AgentLogParser.readsSteps = false }
        state = AgentLogState()
        let entries = AgentLogParser.parseClaude(line, state: &state, now: now)
        let steps = entries.compactMap { entry -> AgentStep? in if case .step(let step) = entry { step } else { nil } }
        suite.expect(steps.map(\.id) == ["toolu_9"] && steps.first?.added == 1, "with Steps on, a tool call is a step")
        state = AgentLogState()
        let later = AgentLogParser.parseClaude(line, state: &state, now: now.addingTimeInterval(AgentLogParser.stepHorizon + 60))
        suite.expect(!later.contains { if case .step = $0 { true } else { false } },
                     "history read at launch is never turned into steps")
    }

    private static func store(_ suite: TestSuite) {
        let store = AgentUsageStore()
        let file = "/Users/me/.claude/projects/app/s1.jsonl"
        let step = AgentStep(id: "t1", date: at, kind: .edit, target: "a.swift", detail: "", added: 1)
        store.apply([.turnBegan(at), .step(step)], file: file, provider: .claude, tracksTurns: true, modified: at, now: at)
        suite.expect(store.steps[file]?.map(\.id) == ["t1"], "a session's steps are kept by its log")
        store.apply([.step(AgentStep(id: "sub", date: at, kind: .read, target: "x", detail: ""))], file: file + "#agent",
                    provider: .claude, tracksTurns: false, parent: file, modified: at, now: at)
        suite.expect(store.steps[file + "#agent"] == nil, "a subagent's log keeps no steps of its own")
        store.dropSteps()
        suite.expect(store.steps.isEmpty, "turning Steps off forgets them all")
    }
}
