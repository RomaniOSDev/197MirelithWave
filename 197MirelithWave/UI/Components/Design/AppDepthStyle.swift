import SwiftUI

enum AppGradients {
    static var primary: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary"), Color("AppAccent")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var surface: LinearGradient {
        LinearGradient(
            colors: [Color("AppSurface"), Color("AppSurface").opacity(0.88)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var surfaceDeep: LinearGradient {
        LinearGradient(
            colors: [Color("AppSurface"), Color("AppBackground").opacity(0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var topSheen: LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(0.08), Color.clear],
            startPoint: .top,
            endPoint: .center
        )
    }

    static var banner: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface"),
                Color("AppPrimary").opacity(0.12),
                Color("AppSurface").opacity(0.95)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func borderStroke(accent: Bool = false) -> LinearGradient {
        if accent {
            return LinearGradient(
                colors: [Color("AppPrimary").opacity(0.55), Color("AppAccent").opacity(0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [Color("AppTextPrimary").opacity(0.1), Color("AppTextPrimary").opacity(0.03)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct AppSurfaceBackground: View {
    var cornerRadius: CGFloat = 18
    var accentBorder: Bool = false
    var borderWidth: CGFloat = 1

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppGradients.surfaceDeep)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppGradients.topSheen)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(AppGradients.borderStroke(accent: accentBorder), lineWidth: accentBorder ? max(borderWidth, 1.5) : borderWidth)
            }
    }
}

extension View {
    /// Gradient depth for scrolling cells — no shadow (GPU-friendly in lists).
    func appCellSurface(cornerRadius: CGFloat = 18, accentBorder: Bool = false) -> some View {
        background(AppSurfaceBackground(cornerRadius: cornerRadius, accentBorder: accentBorder))
    }

    /// Gradient depth for static containers; one composited shadow only.
    func appElevatedSurface(cornerRadius: CGFloat = 18, accentBorder: Bool = false) -> some View {
        background(AppSurfaceBackground(cornerRadius: cornerRadius, accentBorder: accentBorder))
            .compositingGroup()
            .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
    }

    /// Input fields and nested panels.
    func appInsetSurface(cornerRadius: CGFloat = 14) -> some View {
        background(AppSurfaceBackground(cornerRadius: cornerRadius))
    }
}
