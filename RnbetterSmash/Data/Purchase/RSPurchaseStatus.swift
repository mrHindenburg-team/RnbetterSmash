import Foundation

/// Transient, user-facing state of an in-flight or recently completed purchase flow.
///
/// Distinct from entitlement state (which lives in `purchasedProductIDs`); this
/// drives ephemeral UI such as spinners, toasts, and success animations.
enum RSPurchaseStatus: Equatable, Sendable {
    case initial
    case loading
    case success(String)
    case restored
    case nothingToRestore
    case error(String)

    var isLoading: Bool { self == .loading }

    /// Message suitable for display in the custom paywall toast, if any.
    var message: String? {
        switch self {
        case .initial, .loading: nil
        case .success(let text): text
        case .restored: "Purchases restored."
        case .nothingToRestore: "No previous purchases found."
        case .error(let text): text
        }
    }

    var isError: Bool {
        if case .error = self { return true }
        return false
    }
}
