import SwiftUI

/// Empty-state placeholder used by list screens with no content yet.
struct RSEmptyState: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(RSTheme.glow)
            Text(title)
                .font(.rsHeadline(17))
                .foregroundStyle(RSTheme.textPrimary)
            Text(message)
                .font(.rsBody(14))
                .multilineTextAlignment(.center)
                .foregroundStyle(RSTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 20)
    }
}

/// Labeled, glass-styled text field for custom sheets/forms.
struct RSField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var multiline: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.rsCaption(12))
                .foregroundStyle(RSTheme.textSecondary)
            Group {
                if multiline {
                    TextField(placeholder, text: $text, axis: .vertical)
                        .lineLimit(3...6)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(.rsBody(15))
            .foregroundStyle(RSTheme.textPrimary)
            .padding(14)
            .background {
                RoundedRectangle(cornerRadius: RSTheme.cornerSmall, style: .continuous)
                    .fill(RSTheme.glassFill)
                    .overlay(RoundedRectangle(cornerRadius: RSTheme.cornerSmall, style: .continuous)
                        .strokeBorder(RSTheme.glassStroke, lineWidth: 1))
            }
        }
    }
}
