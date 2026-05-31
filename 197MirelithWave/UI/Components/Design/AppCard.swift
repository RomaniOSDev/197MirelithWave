import SwiftUI

struct AppCard<Content: View>: View {
    var accentBorder: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .appElevatedSurface(cornerRadius: 18, accentBorder: accentBorder)
    }
}

struct AppIconBadge: View {
    let iconName: String
    var size: CGFloat = 44
    var iconSize: CGFloat = 20
    var style: BadgeStyle = .primary

    enum BadgeStyle {
        case primary, accent, muted, success, warning

        var colors: (bg: Color, fg: Color) {
            switch self {
            case .primary: return (Color("AppPrimary").opacity(0.18), Color("AppPrimary"))
            case .accent: return (Color("AppAccent").opacity(0.18), Color("AppAccent"))
            case .muted: return (Color("AppTextPrimary").opacity(0.08), Color("AppTextSecondary"))
            case .success: return (Color("AppAccent").opacity(0.22), Color("AppAccent"))
            case .warning: return (Color("AppPrimary").opacity(0.28), Color("AppPrimary"))
            }
        }
    }

    var body: some View {
        let palette = style.colors
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [palette.bg, palette.bg.opacity(0.45)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
                }
                .frame(width: size, height: size)
            Image(systemName: iconName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(palette.fg)
        }
    }
}

struct AppSectionHeader: View {
    let title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(AppGradients.primary)
                        .frame(width: 4, height: 18)
                    Text(title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .padding(.leading, 12)
                }
            }
            Spacer()
            if let actionTitle, let action {
                Button(action: {
                    FeedbackManager.lightTap()
                    action()
                }) {
                    Text(actionTitle)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppPrimary"))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct AppFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(isSelected ? Color("AppBackground") : Color("AppTextSecondary"))
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(
                    Capsule(style: .continuous)
                        .fill(
                            isSelected
                                ? AnyShapeStyle(LinearGradient(
                                    colors: [Color("AppPrimary"), Color("AppAccent")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                : AnyShapeStyle(Color("AppSurface"))
                        )
                        .shadow(color: isSelected ? Color("AppPrimary").opacity(0.25) : .clear, radius: 6, y: 2)
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color("AppTextPrimary").opacity(isSelected ? 0 : 0.08), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct AppStatTile: View {
    let value: String
    let label: String
    var iconName: String?

    var body: some View {
        VStack(spacing: 6) {
            if let iconName {
                AppIconBadge(iconName: iconName, size: 32, iconSize: 14, style: .primary)
            }
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color("AppPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .appInsetSurface(cornerRadius: 14)
    }
}

struct AppEmptyStateView: View {
    let iconName: String
    let title: String
    let message: String
    var buttonTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color("AppPrimary").opacity(0.15), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)
                AppIconBadge(iconName: iconName, size: 72, iconSize: 32, style: .primary)
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.center)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }

            if let buttonTitle, let action {
                PrimaryButton(title: buttonTitle, action: action)
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 32)
    }
}

struct AppSearchField: View {
    @Binding var text: String
    var placeholder: String = "Search"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color("AppTextSecondary"))
            TextField(placeholder, text: $text)
                .foregroundStyle(Color("AppTextPrimary"))
            if !text.isEmpty {
                Button {
                    FeedbackManager.lightTap()
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .appInsetSurface(cornerRadius: 14)
    }
}

struct AppProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 4

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("AppTextPrimary").opacity(0.1), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    LinearGradient(
                        colors: [Color("AppPrimary"), Color("AppAccent")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
    }
}

struct AppTagPill: View {
    let text: String
    var style: PillStyle = .accent

    enum PillStyle {
        case accent, primary, muted, countdown

        var foreground: Color {
            switch self {
            case .accent: return Color("AppAccent")
            case .primary: return Color("AppPrimary")
            case .muted: return Color("AppTextSecondary")
            case .countdown: return Color("AppBackground")
            }
        }

        var background: Color {
            switch self {
            case .accent: return Color("AppAccent").opacity(0.15)
            case .primary: return Color("AppPrimary").opacity(0.15)
            case .muted: return Color("AppTextPrimary").opacity(0.06)
            case .countdown: return Color("AppPrimary")
            }
        }
    }

    var body: some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(style.foreground)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background {
                Capsule(style: .continuous)
                    .fill(
                        style == .countdown
                            ? AnyShapeStyle(AppGradients.primary)
                            : AnyShapeStyle(style.background)
                    )
            }
            .overlay {
                if style != .countdown {
                    Capsule(style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5)
                }
            }
    }
}

struct AppSegmentTab: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.caption.weight(.semibold))
                Text(title)
                    .font(.caption.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(isSelected ? Color("AppBackground") : Color("AppTextSecondary"))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(
                        isSelected
                            ? AnyShapeStyle(LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            : AnyShapeStyle(Color("AppSurface"))
                    )
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color("AppTextPrimary").opacity(isSelected ? 0 : 0.08), lineWidth: 1)
            )
            .shadow(color: isSelected ? Color("AppPrimary").opacity(0.2) : .clear, radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }
}
