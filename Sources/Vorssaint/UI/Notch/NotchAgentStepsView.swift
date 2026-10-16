// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import SwiftUI

/// A step in one line: its tool, what it acts on, and the lines an edit changed.
struct NotchAgentStepLabel: View {
    let step: AgentStep
    var size: CGFloat = 10.5

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: step.kind.symbol)
                .font(.system(size: size - 1, weight: .medium))
                .foregroundStyle(.secondary)
            Text(step.target)
                .font(.system(size: size, design: step.kind == .run || step.kind == .search ? .monospaced : .default))
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(1)
                .truncationMode(.middle)
            NotchAgentStepCounts(step: step, size: size)
        }
    }
}

struct NotchAgentStepCounts: View {
    let step: AgentStep
    var size: CGFloat = 10.5

    var body: some View {
        HStack(spacing: 3) {
            if step.added > 0 { Text("+\(step.added)").foregroundStyle(.green) }
            if step.removed > 0 { Text("−\(step.removed)").foregroundStyle(.red) }
        }
        .font(.system(size: size, weight: .medium))
        .monospacedDigit()
        .lineLimit(1)
        .fixedSize()
    }
}

// MARK: Steps

/// What the busiest session is doing, step by step, newest first. An edit
/// opens its changed lines in place of the list.
struct NotchAgentStepsCard: View {
    let snapshot: AgentUsageSnapshot
    let providers: [AgentProvider]
    let text: NotchAgentStrings
    @State private var opened: String?
    @Environment(\.locale) private var locale

    /// A working session first, then the one that moved last.
    private var session: AgentSessionRow? {
        snapshot.sessions.filter { providers.contains($0.provider) && !$0.steps.isEmpty }
            .max { left, right in
                let l = (left.activity == .working ? 1 : 0, left.steps.last?.date ?? .distantPast)
                let r = (right.activity == .working ? 1 : 0, right.steps.last?.date ?? .distantPast)
                return l < r
            }
    }

    var body: some View {
        let session = self.session
        let steps = Array((session?.steps ?? []).reversed())
        let open = steps.first { $0.id == opened && !$0.diff.isEmpty }
        NotchAgentCardChrome {
            VStack(alignment: .leading, spacing: 6) {
                NotchAgentCardHeader(title: header(session, open: open), symbol: NotchAgentCard.steps.symbol,
                                     tint: session?.provider.tint ?? .secondary) {
                    if open != nil {
                        notchAgentPill(text.back, symbol: "chevron.left", prominent: false, tint: .white) { opened = nil }
                    } else if let session, session.activity == .working {
                        NotchAgentPulse(tint: session.provider.tint, size: 5)
                    }
                }
                if let open {
                    NotchAgentDiffView(step: open)
                } else if steps.isEmpty {
                    Text(text.noSteps).font(.system(size: 10.5)).foregroundStyle(.secondary).lineLimit(2)
                } else {
                    TimelineView(.periodic(from: .now, by: 5)) { context in
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(steps.prefix(4)) { row($0, now: context.date) }
                        }
                    }
                }
            }
        }
        // A session that moves on leaves an opened diff behind.
        .onChange(of: session?.id) { _, _ in opened = nil }
    }

    private func header(_ session: AgentSessionRow?, open: AgentStep?) -> String {
        if let open { return open.target }
        guard let session else { return text.stepsCard }
        let name = session.name ?? (session.project.isEmpty ? session.provider.displayName : session.project)
        return "\(text.stepsCard) · \(name)"
    }

    private func row(_ step: AgentStep, now: Date) -> some View {
        let label = HStack(spacing: 4) {
            NotchAgentStepLabel(step: step, size: 10.5)
            Spacer(minLength: 4)
            if !step.diff.isEmpty {
                Image(systemName: "chevron.right").font(.system(size: 8, weight: .semibold)).foregroundStyle(.tertiary)
            }
            Text(step.date.formatted(.relative(presentation: .numeric, unitsStyle: .narrow).locale(locale)))
                .font(.system(size: 9.5)).monospacedDigit().foregroundStyle(.secondary).lineLimit(1)
        }
        .frame(height: 17)
        .contentShape(Rectangle())
        .help([step.detail, step.target].filter { !$0.isEmpty }.joined(separator: "\n"))
        return Group {
            if step.diff.isEmpty {
                label
            } else {
                Button { opened = step.id } label: { label }
                    .buttonStyle(NotchButtonStyle(cornerRadius: 5))
            }
        }
    }
}

/// An edit's changed lines with a little context, scrolled in place.
struct NotchAgentDiffView: View {
    let step: AgentStep

    var body: some View {
        ScrollView([.vertical, .horizontal]) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(step.diff.enumerated()), id: \.offset) { _, line in
                    Text(prefix(line.kind) + line.text)
                        .font(.system(size: 9.5, design: .monospaced))
                        .foregroundStyle(color(line.kind))
                        .lineLimit(1)
                        .fixedSize()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(color(line.kind).opacity(line.kind == .added || line.kind == .removed ? 0.14 : 0))
                }
            }
            .textSelection(.enabled)
        }
        .scrollIndicators(.automatic)
        .accessibilityLabel([step.target, AgentStepSupport.counts(step) ?? ""].joined(separator: " "))
    }

    private func prefix(_ kind: AgentDiffLine.Kind) -> String {
        switch kind {
        case .same: return "  "
        case .added: return "+ "
        case .removed: return "- "
        case .gap: return "  ⋯"
        }
    }

    private func color(_ kind: AgentDiffLine.Kind) -> Color {
        switch kind {
        case .same: return .white.opacity(0.6)
        case .added: return .green
        case .removed: return .red
        case .gap: return .white.opacity(0.35)
        }
    }
}
