import SwiftUI
import SwiftData

/// Training journal backed by SwiftData. Add, read, and delete session notes.
struct RSJournalView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \RSJournalEntry.date, order: .reverse) private var entries: [RSJournalEntry]

    @State private var showEditor = false

    var body: some View {
        RSScreenScaffold(title: "Training Journal", subtitle: "Log what you worked on") {
            RSPrimaryButton(title: "New Entry", systemImage: "square.and.pencil") {
                showEditor = true
            }

            if entries.isEmpty {
                RSEmptyState(icon: "book.closed.fill",
                             title: "No entries yet",
                             message: "Capture what you drilled, what clicked, and what to fix next session.")
            } else {
                ForEach(entries) { entry in
                    RSJournalRow(entry: entry)
                        .contextMenu {
                            Button(role: .destructive) { delete(entry) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            RSJournalEditor { title, notes, discipline in
                let entry = RSJournalEntry(title: title, body: notes, disciplineRaw: discipline?.rawValue)
                context.insert(entry)
                try? context.save()
            }
        }
    }

    private func delete(_ entry: RSJournalEntry) {
        context.delete(entry)
        try? context.save()
        RSHaptics.tap()
    }
}

struct RSJournalRow: View {
    let entry: RSJournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.title).font(.rsHeadline(16)).foregroundStyle(RSTheme.textPrimary)
                Spacer()
                if let discipline = entry.discipline {
                    RSTag(text: discipline.title, tint: discipline.accent)
                }
            }
            Text(entry.date, format: .dateTime.day().month().year())
                .font(.rsCaption(11)).foregroundStyle(RSTheme.textTertiary)
            if !entry.body.isEmpty {
                Text(entry.body).font(.rsBody(14)).foregroundStyle(RSTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 14)
    }
}

/// Sheet for authoring a journal entry.
struct RSJournalEditor: View {
    var onSave: (String, String, RSDiscipline?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var notes = ""
    @State private var discipline: RSDiscipline?

    private var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                RSAnimatedBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        RSField(title: "Title", text: $title, placeholder: "e.g. Sparring — footwork focus")
                        RSField(title: "Notes", text: $notes, placeholder: "What worked, what to fix…", multiline: true)

                        Text("Discipline (optional)").font(.rsCaption(12)).foregroundStyle(RSTheme.textSecondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(RSDiscipline.allCases) { d in
                                    Button {
                                        discipline = (discipline == d) ? nil : d
                                    } label: {
                                        Text(d.title)
                                            .font(.rsCaption(12))
                                            .foregroundStyle(discipline == d ? RSTheme.voidPurple : RSTheme.textPrimary)
                                            .padding(.horizontal, 12).padding(.vertical, 8)
                                            .background {
                                                Capsule().fill(discipline == d ? AnyShapeStyle(d.accent) : AnyShapeStyle(RSTheme.glassFill))
                                                    .overlay(Capsule().strokeBorder(d.accent.opacity(0.4), lineWidth: 1))
                                            }
                                    }
                                    .buttonStyle(.rsPressable)
                                }
                            }
                        }

                        RSPrimaryButton(title: "Save Entry", systemImage: "checkmark.circle.fill") {
                            onSave(title, notes, discipline)
                            RSHaptics.success()
                            dismiss()
                        }
                        .disabled(!canSave)
                        .opacity(canSave ? 1 : 0.5)
                    }
                    .padding(18)
                }
            }
            .navigationTitle("New Entry")
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
