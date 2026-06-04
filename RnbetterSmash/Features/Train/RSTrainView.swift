import SwiftUI

/// Training hub: programs, weekly planner, and interactive training systems
/// (quiz, tactical simulator, reaction trainer).
struct RSTrainView: View {
    @Binding var showPaywall: Bool

    @Environment(RSProgressManager.self) private var manager
    @Environment(SubscriptionManagerBPV.self) private var purchases

    var body: some View {
        NavigationStack {
            RSScreenScaffold(title: "Train", subtitle: "Build the engine and the mind") {
                // Streak / today card
                trainingPulse

                RSSectionHeader(title: "Interactive Systems", systemImage: "gamecontroller.fill")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    NavigationLink(value: RSTrainDest.quiz) {
                        RSSystemTile(title: "Combat Quiz", subtitle: "Test your knowledge", icon: "questionmark.circle.fill", tint: RSTheme.electricBlue)
                    }.buttonStyle(.plain)
                    NavigationLink(value: RSTrainDest.tactics) {
                        RSSystemTile(title: "Tactical Sim", subtitle: "Decision training", icon: "brain.filled.head.profile", tint: RSTheme.royalPurple)
                    }.buttonStyle(.plain)
                    NavigationLink(value: RSTrainDest.reaction) {
                        RSSystemTile(title: "Reaction Lab", subtitle: "Sharpen reflexes", icon: "bolt.fill", tint: RSTheme.icyCyan)
                    }.buttonStyle(.plain)
                    NavigationLink(value: RSTrainDest.planner) {
                        RSSystemTile(title: "Weekly Planner", subtitle: "Structure your week", icon: "calendar", tint: RSTheme.glowCyan)
                    }.buttonStyle(.plain)
                }

                RSSectionHeader(title: "Training Programs", systemImage: "list.bullet.clipboard.fill")
                ForEach(RSContentLibrary.shared.programs) { program in
                    let locked = program.requiredPack.map { !purchases.isPurchased($0) } ?? false
                    NavigationLink(value: RSTrainDest.program(program.id)) {
                        RSProgramCard(program: program, locked: locked)
                    }
                    .buttonStyle(.plain)
                    .disabled(locked)
                    .opacity(locked ? 0.6 : 1)
                }

                if !purchases.hasPremiumAccess {
                    RSPremiumTeaser { showPaywall = true }
                }
            }
            .navigationDestination(for: RSTrainDest.self) { dest in
                switch dest {
                case .quiz: RSQuizView()
                case .tactics: RSTacticalScenarioView()
                case .reaction: RSReactionTrainerView()
                case .planner: RSWeeklyPlannerView()
                case .program(let id):
                    if let program = RSContentLibrary.shared.programs.first(where: { $0.id == id }) {
                        RSProgramDetailView(program: program)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .tint(RSTheme.icyCyan)
    }

    private var trainingPulse: some View {
        HStack(spacing: 16) {
            RSProgressRing(progress: min(1, Double(manager.currentStreak) / 7),
                           size: 84, label: "streak", value: "\(manager.currentStreak)")
            VStack(alignment: .leading, spacing: 6) {
                Text("Keep the streak alive").font(.rsHeadline(17)).foregroundStyle(RSTheme.textPrimary)
                Text("Log any training to extend your streak and earn XP.")
                    .font(.rsCaption(12)).foregroundStyle(RSTheme.textSecondary)
                RSGhostButton(title: "Log a Session Today", systemImage: "checkmark.circle") {
                    manager.logTrainingSession()
                    RSHaptics.success()
                }
            }
        }
        .rsGlassCard(cornerRadius: RSTheme.cornerLarge, padding: 16)
    }
}

enum RSTrainDest: Hashable {
    case quiz, tactics, reaction, planner
    case program(String)
}

struct RSSystemTile: View {
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).font(.system(size: 28, weight: .bold)).foregroundStyle(tint)
            Spacer(minLength: 0)
            Text(title).font(.rsHeadline(16)).foregroundStyle(RSTheme.textPrimary)
            Text(subtitle).font(.rsCaption(11)).foregroundStyle(RSTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: RSTheme.cornerMedium, style: .continuous)
                .fill(RSTheme.glassFill)
                .overlay(RoundedRectangle(cornerRadius: RSTheme.cornerMedium, style: .continuous)
                    .strokeBorder(tint.opacity(0.35), lineWidth: 1))
        }
    }
}

struct RSProgramCard: View {
    let program: RSTrainingProgram
    let locked: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(program.title).font(.rsHeadline(17)).foregroundStyle(RSTheme.textPrimary)
                Spacer()
                Image(systemName: locked ? "lock.fill" : "chevron.right")
                    .foregroundStyle(locked ? RSTheme.warning : RSTheme.textTertiary)
            }
            Text(program.focus).font(.rsCaption(12)).foregroundStyle(RSTheme.textSecondary)
            HStack(spacing: 8) {
                RSTag(text: program.level, tint: RSTheme.icyCyan)
                RSTag(text: "\(program.days.count) days", tint: RSTheme.electricBlue)
                RSTag(text: "\(program.totalMinutes) min", tint: RSTheme.success)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 16)
    }
}
