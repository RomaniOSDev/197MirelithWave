import SwiftUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakes: CGFloat = 3
    var animatableData: CGFloat

    init(animatableData: CGFloat = 0) {
        self.animatableData = animatableData
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(translationX: amount * sin(animatableData * .pi * shakes), y: 0)
        )
    }
}

struct ShakeModifier: ViewModifier {
    @Binding var trigger: Bool

    func body(content: Content) -> some View {
        content
            .modifier(ShakeEffect(animatableData: trigger ? 1 : 0))
            .animation(trigger ? .default : nil, value: trigger)
            .onChange(of: trigger) { newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        trigger = false
                    }
                }
            }
    }
}

extension View {
    func shake(trigger: Binding<Bool>) -> some View {
        modifier(ShakeModifier(trigger: trigger))
    }
}
