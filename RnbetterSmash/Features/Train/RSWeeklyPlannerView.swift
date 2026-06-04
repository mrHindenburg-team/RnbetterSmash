import SwiftUI

/// Weekly training planner. Assign a discipline focus to each day of the week.
/// State is local to the session; logging a planned day extends the streak.
struct RSWeeklyPlannerView: View {
    @Environment(RSProgressManager.self) private var manager

    private let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    @State private var plan: [Int: RSDiscipline] = [:]
    @State private var editingDay: Int?

    var body: some View {
        RSScreenScaffold(title: "Weekly Planner", subtitle: "Engineer your training week") {
            ForEach(0..<7, id: \.self) { day in
                dayRow(day)
            }

            let filled = plan.count
            Text("\(filled)/7 days planned")
                .font(.rsCaption(12)).foregroundStyle(RSTheme.textSecondary)
                .frame(maxWidth: .infinity)
        }
        .sheet(item: Binding(get: { editingDay.map(RSDayBox.init) },
                             set: { editingDay = $0?.day })) { box in
            disciplinePicker(for: box.day)
        }
    }

    private func dayRow(_ day: Int) -> some View {
        Button {
            editingDay = day
        } label: {
            HStack(spacing: 14) {
                Text(weekdays[day])
                    .font(.rsHeadline(15)).foregroundStyle(RSTheme.textPrimary)
                    .frame(width: 46, alignment: .leading)
                if let discipline = plan[day] {
                    Image(systemName: discipline.symbol).foregroundStyle(discipline.accent)
                    Text(discipline.title).font(.rsBody(15)).foregroundStyle(RSTheme.textPrimary)
                } else {
                    Text("Rest / unplanned").font(.rsBody(15)).foregroundStyle(RSTheme.textTertiary)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").foregroundStyle(RSTheme.textTertiary)
            }
            .rsGlassCard(cornerRadius: RSTheme.cornerSmall, padding: 14)
        }
        .buttonStyle(.plain)
    }

    private func disciplinePicker(for day: Int) -> some View {
        NavigationStack {
            ZStack {
                RSAnimatedBackground()
                ScrollView {
                    VStack(spacing: 12) {
                        Button {
                            plan[day] = nil
                            editingDay = nil
                        } label: {
                            Text("Rest Day").font(.rsHeadline(16)).foregroundStyle(RSTheme.textPrimary)
                                .frame(maxWidth: .infinity).rsGlassCard(cornerRadius: RSTheme.cornerSmall, padding: 16)
                        }.buttonStyle(.plain)

                        ForEach(RSDiscipline.allCases) { discipline in
                            Button {
                                plan[day] = discipline
                                manager.logTrainingSession()
                                editingDay = nil
                            } label: {
                                HStack {
                                    Image(systemName: discipline.symbol).foregroundStyle(discipline.accent)
                                    Text(discipline.title).font(.rsHeadline(16)).foregroundStyle(RSTheme.textPrimary)
                                    Spacer()
                                }
                                .rsGlassCard(cornerRadius: RSTheme.cornerSmall, padding: 16)
                            }.buttonStyle(.plain)
                        }
                    }
                    .padding(18)
                }
            }
            .navigationTitle("Plan \(weekdays[day])")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .preferredColorScheme(.dark)
    }
}

/// Identifiable wrapper so an Int day can drive `.sheet(item:)`.
private struct RSDayBox: Identifiable {
    let day: Int
    var id: Int { day }
}
