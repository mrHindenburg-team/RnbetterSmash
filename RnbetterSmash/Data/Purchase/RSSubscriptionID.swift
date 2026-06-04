import Foundation

/// Identifiers for the two non-consumable, one-time unlocks sold via StoreKit 2.
///
/// The app uses **no subscriptions**. Each case maps to a product configured in
/// the App Store / local StoreKit configuration file. Both packs gate real,
/// fully implemented functionality that ships in the app at launch.
enum RSSubscriptionID: String, CaseIterable, Codable, Hashable, Sendable {

    /// Unlocks unlimited on-device AI coaching, advanced training systems,
    /// premium educational content, expanded tactical simulations, and
    /// advanced progression analytics.
    case eliteFighterPack = "RnbetterSmash.eliteFighterPack"

    /// Unlocks advanced learning pathways, premium sports-science modules,
    /// expanded training programs, and exclusive progression systems.
    case championAcademyPack = "RnbetterSmash.championAcademyPack"

    var displayName: String {
        switch self {
        case .eliteFighterPack: "Elite Fighter Pack"
        case .championAcademyPack: "Champion Academy Pack"
        }
    }

    /// Short marketing tagline. Describes only features that genuinely exist.
    var tagline: String {
        switch self {
        case .eliteFighterPack:
            "Unlimited AI coaching + advanced premium lessons"
        case .championAcademyPack:
            "Premium sports-science modules + advanced training program"
        }
    }

    /// Concrete, already-implemented capabilities unlocked by this pack.
    /// Each line maps to functionality that actually ships and is gated in-app.
    var unlockedCapabilities: [String] {
        switch self {
        case .eliteFighterPack:
            [
                "Unlimited on-device AI coaching — removes the 5-per-session free cap",
                "Unlocks the premium lesson \"Building Combinations\" (Boxing)",
                "Unlocks the premium lesson \"The Closed Guard\" (Brazilian Jiu-Jitsu)",
                "Unlocks the premium lesson \"The Four Ranges of MMA\""
            ]
        case .championAcademyPack:
            [
                "Unlocks the \"Recovery Science\" sports-science module",
                "Unlocks the \"Sports Nutrition Basics\" sports-science module",
                "Unlocks the \"Fight Engine: Conditioning Block\" training program"
            ]
        }
    }
}
