import SwiftUI

/// Reader for a sports-science module.
struct RSScienceDetailView: View {
    let module: RSScienceModule

    @Environment(SubscriptionManagerBPV.self) private var purchases

    private var locked: Bool {
        if let pack = module.requiredPack { return !purchases.isPurchased(pack) }
        return false
    }

    var body: some View {
        RSScreenScaffold(title: module.title, subtitle: "Sports Science") {
            HStack {
                Image(systemName: module.icon)
                    .font(.system(size: 40, weight: .black))
                    .foregroundStyle(RSTheme.glow)
                Spacer()
                if module.isPremium { RSTag(text: "Premium", tint: RSTheme.warning) }
            }
            .rsGlassCard(cornerRadius: RSTheme.cornerLarge, padding: 18)

            if locked {
                VStack(spacing: 14) {
                    Image(systemName: "lock.fill").font(.rsDisplay(40)).foregroundStyle(RSTheme.warning)
                    Text("This module is part of the \(module.requiredPack?.displayName ?? "premium").")
                        .font(.rsBody(15)).multilineTextAlignment(.center)
                        .foregroundStyle(RSTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 24)
            } else {
                Text(module.body)
                    .font(.rsBody(16))
                    .foregroundStyle(RSTheme.textPrimary)
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 18)
            }
        }
    }
}
