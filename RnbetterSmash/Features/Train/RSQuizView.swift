import SwiftUI

/// Combat-sports quiz. Awards XP and can unlock the "Flawless" achievement.
struct RSQuizView: View {
    @Environment(RSProgressManager.self) private var manager

    private let questions = RSContentLibrary.shared.quiz
    @State private var index = 0
    @State private var selected: Int?
    @State private var correctCount = 0
    @State private var finished = false

    var body: some View {
        RSScreenScaffold(title: "Combat Quiz", subtitle: "Sharpen your fight IQ") {
            if finished {
                results
            } else {
                quizBody
            }
        }
    }

    private var quizBody: some View {
        let q = questions[index]
        return VStack(alignment: .leading, spacing: 16) {
            RSEnergyBar(progress: Double(index) / Double(questions.count))

            HStack {
                RSTag(text: q.discipline.title, tint: q.discipline.accent)
                Spacer()
                Text("\(index + 1)/\(questions.count)").font(.rsCaption(12)).foregroundStyle(RSTheme.textSecondary)
            }

            Text(q.prompt)
                .font(.rsTitle(20))
                .foregroundStyle(RSTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 18)

            ForEach(Array(q.options.enumerated()), id: \.offset) { i, option in
                RSQuizOption(text: option,
                             state: optionState(for: i, correct: q.correctIndex),
                             action: { choose(i, correct: q.correctIndex) })
            }

            if selected != nil {
                Text(q.explanation)
                    .font(.rsBody(14)).foregroundStyle(RSTheme.textSecondary)
                    .rsGlassCard(cornerRadius: RSTheme.cornerSmall, padding: 14)
                RSPrimaryButton(title: index == questions.count - 1 ? "See Results" : "Next Question",
                                systemImage: "arrow.right", action: next)
            }
        }
    }

    private var results: some View {
        VStack(spacing: 18) {
            RSProgressRing(progress: Double(correctCount) / Double(questions.count),
                           size: 150, label: "score",
                           value: "\(correctCount)/\(questions.count)")
            Text(correctCount == questions.count ? "Flawless! Championship IQ." : "Solid work—review and run it back.")
                .font(.rsHeadline(17)).foregroundStyle(RSTheme.textPrimary)
                .multilineTextAlignment(.center)
            RSPrimaryButton(title: "Retake Quiz", systemImage: "arrow.counterclockwise", action: restart)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
    }

    private func optionState(for i: Int, correct: Int) -> RSQuizOption.State {
        guard let selected else { return .idle }
        if i == correct { return .correct }
        if i == selected { return .wrong }
        return .dimmed
    }

    private func choose(_ i: Int, correct: Int) {
        guard selected == nil else { return }
        selected = i
        if i == correct { correctCount += 1; RSHaptics.success() } else { RSHaptics.tap() }
    }

    private func next() {
        if index == questions.count - 1 {
            manager.recordQuizResult(correct: correctCount, total: questions.count)
            withAnimation { finished = true }
        } else {
            withAnimation { index += 1; selected = nil }
        }
    }

    private func restart() {
        withAnimation { index = 0; selected = nil; correctCount = 0; finished = false }
    }
}

struct RSQuizOption: View {
    enum State { case idle, correct, wrong, dimmed }
    let text: String
    let state: State
    let action: () -> Void

    private var tint: Color {
        switch state {
        case .idle: RSTheme.glassStroke
        case .correct: RSTheme.success
        case .wrong: RSTheme.danger
        case .dimmed: RSTheme.glassStroke
        }
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text).font(.rsBody(15)).foregroundStyle(RSTheme.textPrimary)
                Spacer()
                if state == .correct { Image(systemName: "checkmark.circle.fill").foregroundStyle(RSTheme.success) }
                if state == .wrong { Image(systemName: "xmark.circle.fill").foregroundStyle(RSTheme.danger) }
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: RSTheme.cornerMedium, style: .continuous)
                    .fill(RSTheme.glassFill)
                    .overlay(RoundedRectangle(cornerRadius: RSTheme.cornerMedium, style: .continuous)
                        .strokeBorder(tint, lineWidth: 1.5))
            }
            .opacity(state == .dimmed ? 0.5 : 1)
        }
        .buttonStyle(.plain)
    }
}
