import SwiftUI

struct SuccessCheckmarkOverlay: View {
    @Binding var isVisible: Bool

    var body: some View {
        ZStack {
            if isVisible {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color("AppPrimary"))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isVisible)
        .allowsHitTesting(false)
    }
}

struct PulseHighlightModifier: ViewModifier {
    @Binding var isPulsing: Bool

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("AppAccent").opacity(isPulsing ? 0.35 : 0))
                    .animation(.easeInOut(duration: 0.4), value: isPulsing)
            )
            .onChange(of: isPulsing) { pulsing in
                if pulsing {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isPulsing = false
                    }
                }
            }
    }
}

extension View {
    func pulseHighlight(_ isPulsing: Binding<Bool>) -> some View {
        modifier(PulseHighlightModifier(isPulsing: isPulsing))
    }
}

struct SuccessFeedback {
    static func show(checkmark: Binding<Bool>, pulse: Binding<Bool>? = nil) {
        FeedbackManager.success()
        checkmark.wrappedValue = true
        if let pulse {
            pulse.wrappedValue = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            checkmark.wrappedValue = false
        }
    }
}
