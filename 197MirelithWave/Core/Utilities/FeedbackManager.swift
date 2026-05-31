import AudioToolbox
import UIKit

enum FeedbackManager {
    static func lightTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func mediumTap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        AudioServicesPlaySystemSound(1057)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func tick() {
        AudioServicesPlaySystemSound(1003)
    }

    static func addDestinationSound() {
        AudioServicesPlaySystemSound(1104)
    }

    static func setCurrencySound() {
        AudioServicesPlaySystemSound(1103)
    }

    static func checklistComplete() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }

    static func achievementUnlocked() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
