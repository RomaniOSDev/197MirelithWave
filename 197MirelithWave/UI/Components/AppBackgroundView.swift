import SwiftUI

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color("AppBackground"),
                    Color("AppSurface").opacity(0.35),
                    Color("AppBackground")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color("AppPrimary").opacity(0.12), Color.clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 340
            )

            RadialGradient(
                colors: [Color("AppAccent").opacity(0.08), Color.clear],
                center: .bottomLeading,
                startRadius: 10,
                endRadius: 300
            )

            LinearGradient(
                colors: [Color.clear, Color("AppPrimary").opacity(0.04), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        .drawingGroup()
        .ignoresSafeArea()
    }
}
