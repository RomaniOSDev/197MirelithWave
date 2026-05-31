import SwiftUI

private struct OnboardingPageModel {
    let stepLabel: String
    let headline: String
    let description: String
    let icon: String
    let highlights: [String]
}

struct OnboardingView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var currentPage = 0
    @State private var illustrationScale: CGFloat = 0.88
    @State private var illustrationOpacity: Double = 0
    @State private var contentOffset: CGFloat = 24

    private let pages: [OnboardingPageModel] = [
        OnboardingPageModel(
            stepLabel: "Plan",
            headline: "Plan Your Trip",
            description: "Build detailed itineraries, track countdowns, and keep every destination organized in one place.",
            icon: "map.fill",
            highlights: ["Itineraries", "Countdown", "Time zones"]
        ),
        OnboardingPageModel(
            stepLabel: "Pack",
            headline: "Pack Efficiently",
            description: "Use smart packing lists and templates so nothing important gets left behind before you depart.",
            icon: "suitcase.fill",
            highlights: ["Checklists", "Templates", "Progress"]
        ),
        OnboardingPageModel(
            stepLabel: "Go",
            headline: "Get Started Now",
            description: "Add your first destination and unlock tools for currency, documents, budget, and more.",
            icon: "airplane.departure",
            highlights: ["Documents", "Budget", "Awards"]
        )
    ]

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingPage(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                bottomPanel
            }
        }
        .onChange(of: currentPage) { _ in animatePageTransition() }
        .onAppear { animatePageTransition() }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            AppTagPill(text: "Step \(currentPage + 1) of \(pages.count)", style: .primary)
            Spacer()
            if currentPage < pages.count - 1 {
                Button {
                    FeedbackManager.lightTap()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage = pages.count - 1
                    }
                } label: {
                    Text("Skip")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Page

    private func onboardingPage(page: OnboardingPageModel) -> some View {
        VStack(spacing: 28) {
            Spacer(minLength: 8)

            illustrationBlock(page: page)
                .scaleEffect(illustrationScale)
                .opacity(illustrationOpacity)

            contentCard(page: page)
                .offset(y: contentOffset)
                .opacity(illustrationOpacity)

            Spacer(minLength: 16)
        }
        .padding(.horizontal, 20)
    }

    private func illustrationBlock(page: OnboardingPageModel) -> some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color("AppPrimary").opacity(0.22), Color.clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 130
                    )
                )
                .frame(width: 260, height: 260)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color("AppAccent").opacity(0.12), Color.clear],
                        center: .bottomTrailing,
                        startRadius: 10,
                        endRadius: 100
                    )
                )
                .frame(width: 220, height: 220)

            ForEach(0..<3, id: \.self) { ring in
                Circle()
                    .strokeBorder(
                        AppGradients.borderStroke(accent: true),
                        lineWidth: 1.5
                    )
                    .opacity(0.35 - Double(ring) * 0.1)
                    .frame(width: CGFloat(120 + ring * 36), height: CGFloat(120 + ring * 36))
            }

            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(AppGradients.surfaceDeep)
                        .frame(width: 120, height: 120)
                        .overlay {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(AppGradients.topSheen)
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .strokeBorder(AppGradients.borderStroke(accent: true), lineWidth: 1.5)
                        }

                    AppIconBadge(iconName: page.icon, size: 72, iconSize: 32, style: .primary)
                }
                .compositingGroup()
                .shadow(color: Color("AppPrimary").opacity(0.25), radius: 14, y: 6)

                AppTagPill(text: page.stepLabel, style: .countdown)
            }
        }
        .frame(height: 280)
    }

    private func contentCard(page: OnboardingPageModel) -> some View {
        AppCard(accentBorder: true) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(AppGradients.primary)
                        .frame(width: 4, height: 22)
                    Text(page.headline)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                }

                Text(page.description)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(page.highlights, id: \.self) { highlight in
                            AppTagPill(text: highlight, style: .accent)
                        }
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Bottom Panel

    private var bottomPanel: some View {
        VStack(spacing: 20) {
            HStack(spacing: 10) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule(style: .continuous)
                        .fill(
                            index == currentPage
                                ? AnyShapeStyle(AppGradients.primary)
                                : AnyShapeStyle(Color("AppTextSecondary").opacity(0.25))
                        )
                        .frame(width: index == currentPage ? 28 : 8, height: 8)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                }
            }

            HStack(spacing: 12) {
                if currentPage > 0 && currentPage < pages.count - 1 {
                    PrimaryButton(title: "Back", iconName: "arrow.left", style: .secondary) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage -= 1
                        }
                    }
                }

                PrimaryButton(
                    title: currentPage == pages.count - 1 ? "Get Started" : "Next",
                    iconName: currentPage == pages.count - 1 ? "arrow.right.circle.fill" : "arrow.right"
                ) {
                    advancePage()
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 36)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppGradients.surfaceDeep)
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(AppGradients.topSheen)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(AppGradients.borderStroke(), lineWidth: 1)
                }
                .ignoresSafeArea(edges: .bottom)
        )
        .compositingGroup()
        .shadow(color: .black.opacity(0.18), radius: 16, y: -4)
    }

    // MARK: - Actions

    private func advancePage() {
        if currentPage < pages.count - 1 {
            FeedbackManager.lightTap()
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        } else {
            FeedbackManager.mediumTap()
            FeedbackManager.success()
            store.completeOnboarding()
        }
    }

    private func animatePageTransition() {
        illustrationScale = 0.88
        illustrationOpacity = 0
        contentOffset = 24
        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
            illustrationScale = 1.0
            illustrationOpacity = 1.0
            contentOffset = 0
        }
    }
}
