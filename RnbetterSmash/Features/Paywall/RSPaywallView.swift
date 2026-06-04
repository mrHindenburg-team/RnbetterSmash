import SwiftUI
import StoreKit

/// Fully custom paywall for the two non-consumable packs. Reads and writes only
/// through the existing `SubscriptionManagerBPV` — the single source of truth.
struct RSPaywallView: View {
    @Environment(SubscriptionManagerBPV.self) private var purchases
    @Environment(\.dismiss) private var dismiss

    /// Public privacy-policy page. Replace with your hosted policy URL.
    static let privacyPolicyURL = URL(string: "https://rnbetter.app/privacy")!

    var body: some View {
        ZStack {
            RSAnimatedBackground(intensity: 1.2)

            ScrollView {
                VStack(spacing: 20) {
                    header

                    ForEach(RSSubscriptionID.allCases, id: \.self) { pack in
                        RSPackCard(pack: pack,
                                   product: purchases.product(for: pack),
                                   owned: purchases.isPurchased(pack),
                                   isLoading: purchases.purchaseStatus.isLoading) {
                            if let product = purchases.product(for: pack) {
                                Task { await purchases.buyProduct(product) }
                            }
                        }
                    }

                    Button("Restore Purchases") {
                        Task { await purchases.restorePurchases() }
                    }
                    .font(.rsHeadline(15))
                    .foregroundStyle(RSTheme.textSecondary)

                    // Privacy policy — opens in the browser. Replace with your URL.
                    Link("Privacy Policy", destination: Self.privacyPolicyURL)
                        .font(.rsHeadline(15))
                        .foregroundStyle(RSTheme.glowCyan)

                    Text("One-time purchases. No subscriptions. Buy once, own forever.")
                        .font(.rsCaption(11))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(RSTheme.textTertiary)
                        .padding(.horizontal, 30)
                }
                .padding(20)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)

            if let message = purchases.purchaseStatus.message {
                toast(message, isError: purchases.purchaseStatus.isError)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.rsTitle(26))
                    .foregroundStyle(RSTheme.textSecondary)
                    .padding(18)
            }
            .accessibilityLabel("Close")
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(RSTheme.energy).frame(width: 80, height: 80)
                    .shadow(color: RSTheme.electricBlue.opacity(0.7), radius: 22)
                Image(systemName: "crown.fill").font(.system(size: 38, weight: .black)).foregroundStyle(.white)
            }
            Text("Unlock Your Full Potential")
                .font(.rsTitle(26)).multilineTextAlignment(.center).foregroundStyle(RSTheme.textPrimary)
            Text("Own it once. Train forever, completely offline.")
                .font(.rsBody(14)).foregroundStyle(RSTheme.textSecondary)
        }
        .padding(.top, 30)
    }

    private func toast(_ message: String, isError: Bool) -> some View {
        VStack {
            Spacer()
            HStack(spacing: 10) {
                Image(systemName: isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                    .foregroundStyle(isError ? RSTheme.danger : RSTheme.success)
                Text(message).font(.rsCaption(13)).foregroundStyle(RSTheme.textPrimary)
            }
            .padding(.horizontal, 18).padding(.vertical, 12)
            .background(.ultraThinMaterial, in: Capsule())
            .environment(\.colorScheme, .dark)
            .padding(.bottom, 40)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

/// A single purchasable pack card. Descriptions list only real, shipped features.
struct RSPackCard: View {
    let pack: RSSubscriptionID
    let product: Product?
    let owned: Bool
    let isLoading: Bool
    let onBuy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: pack == .eliteFighterPack ? "bolt.shield.fill" : "graduationcap.fill")
                    .font(.rsTitle(24)).foregroundStyle(RSTheme.glow)
                VStack(alignment: .leading, spacing: 2) {
                    Text(pack.displayName).font(.rsHeadline(18)).foregroundStyle(RSTheme.textPrimary)
                    Text(pack.tagline).font(.rsCaption(11)).foregroundStyle(RSTheme.textSecondary)
                }
                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(pack.unlockedCapabilities, id: \.self) { capability in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 13)).foregroundStyle(RSTheme.success)
                        Text(capability).font(.rsBody(13)).foregroundStyle(RSTheme.textSecondary)
                        Spacer(minLength: 0)
                    }
                }
            }

            if owned {
                Label("Unlocked", systemImage: "checkmark.seal.fill")
                    .font(.rsHeadline(16)).foregroundStyle(RSTheme.success)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
            } else {
                RSPrimaryButton(title: buyTitle, systemImage: "lock.open.fill", action: onBuy)
                    .disabled(isLoading || product == nil)
            }
        }
        .rsGlassCard(cornerRadius: RSTheme.cornerLarge, padding: 18)
    }

    private var buyTitle: String {
        if let product { return "Unlock · \(product.displayPrice)" }
        return "Unavailable"
    }
}
