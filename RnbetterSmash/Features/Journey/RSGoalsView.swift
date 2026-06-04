import SwiftUI
import SwiftData

/// Goal-management system backed by SwiftData. Create goals, mark complete, delete.
struct RSGoalsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \RSGoal.createdAt, order: .reverse) private var goals: [RSGoal]

    @State private var showEditor = false

    private var active: [RSGoal] { goals.filter { !$0.isComplete } }
    private var done: [RSGoal] { goals.filter { $0.isComplete } }

    var body: some View {
        RSScreenScaffold(title: "Goals", subtitle: "Set the target, then chase it") {
            RSPrimaryButton(title: "New Goal", systemImage: "target") { showEditor = true }

            if goals.isEmpty {
                RSEmptyState(icon: "target",
                             title: "No goals yet",
                             message: "Set a clear, specific goal—\u{201C}land 50 clean jabs on the bag daily\u{201D}—and track it here.")
            } else {
                if !active.isEmpty {
                    RSSectionHeader(title: "Active", systemImage: "flame.fill")
                    ForEach(active) { goal in RSGoalRow(goal: goal, toggle: { toggle(goal) }, delete: { delete(goal) }) }
                }
                if !done.isEmpty {
                    RSSectionHeader(title: "Completed", systemImage: "checkmark.seal.fill")
                    ForEach(done) { goal in RSGoalRow(goal: goal, toggle: { toggle(goal) }, delete: { delete(goal) }) }
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            RSGoalEditor { title, detail in
                context.insert(RSGoal(title: title, detail: detail))
                try? context.save()
            }
        }
    }

    private func toggle(_ goal: RSGoal) {
        goal.isComplete.toggle()
        try? context.save()
        RSHaptics.success()
    }

    private func delete(_ goal: RSGoal) {
        context.delete(goal)
        try? context.save()
        RSHaptics.tap()
    }
}

struct RSGoalRow: View {
    let goal: RSGoal
    let toggle: () -> Void
    let delete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: toggle) {
                Image(systemName: goal.isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.rsTitle(22))
                    .foregroundStyle(goal.isComplete ? RSTheme.success : RSTheme.textTertiary)
            }
            .buttonStyle(.rsPressable)
            .accessibilityLabel(goal.isComplete ? "Mark goal active" : "Mark goal complete")

            VStack(alignment: .leading, spacing: 3) {
                Text(goal.title)
                    .font(.rsHeadline(16))
                    .foregroundStyle(RSTheme.textPrimary)
                    .strikethrough(goal.isComplete, color: RSTheme.textTertiary)
                if !goal.detail.isEmpty {
                    Text(goal.detail).font(.rsCaption(12)).foregroundStyle(RSTheme.textSecondary)
                }
            }
            Spacer(minLength: 0)
        }
        .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 14)
        .contextMenu {
            Button(role: .destructive, action: delete) { Label("Delete", systemImage: "trash") }
        }
    }
}

struct RSGoalEditor: View {
    var onSave: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var detail = ""

    private var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                RSAnimatedBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        RSField(title: "Goal", text: $title, placeholder: "e.g. Train 4 days every week")
                        RSField(title: "Details", text: $detail, placeholder: "Why it matters, how you'll measure it…", multiline: true)
                        RSPrimaryButton(title: "Save Goal", systemImage: "checkmark.circle.fill") {
                            onSave(title, detail)
                            RSHaptics.success()
                            dismiss()
                        }
                        .disabled(!canSave)
                        .opacity(canSave ? 1 : 0.5)
                    }
                    .padding(18)
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundStyle(RSTheme.textSecondary)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
