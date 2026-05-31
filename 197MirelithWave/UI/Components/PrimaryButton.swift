import SwiftUI

struct PrimaryButton: View {
    let title: String
    var iconName: String?
    var style: ButtonVariant = .primary
    let action: () -> Void

    enum ButtonVariant {
        case primary, secondary, ghost
    }

    var body: some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let iconName {
                    Image(systemName: iconName)
                        .font(.subheadline.weight(.semibold))
                }
                Text(title)
                    .font(.headline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(borderColor, lineWidth: style == .secondary ? 1.5 : 0)
            )
            .overlay(alignment: .top) {
                if style == .primary {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppGradients.topSheen)
                        .frame(height: 20)
                        .allowsHitTesting(false)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .compositingGroup()
            .shadow(color: style == .primary ? Color("AppPrimary").opacity(0.3) : .clear, radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return Color("AppBackground")
        case .secondary: return Color("AppPrimary")
        case .ghost: return Color("AppAccent")
        }
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .primary:
            AppGradients.primary
        case .secondary:
            AppGradients.surfaceDeep
        case .ghost:
            Color.clear
        }
    }

    private var borderColor: Color {
        switch style {
        case .secondary: return Color("AppPrimary").opacity(0.45)
        default: return .clear
        }
    }
}

struct DestructiveButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(role: .destructive) {
            FeedbackManager.lightTap()
            action()
        } label: {
            Text(title)
                .font(.headline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.red.opacity(0.85))
                )
        }
        .buttonStyle(.plain)
    }
}
