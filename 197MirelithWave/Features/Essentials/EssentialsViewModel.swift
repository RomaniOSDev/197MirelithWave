import Combine
import Foundation

final class EssentialsViewModel: ObservableObject {
    @Published var showCurrencySheet = false
    @Published var showSuccessCheckmark = false
    @Published var expandedPhraseIDs: Set<String> = []
    @Published var conversionAmount: String = "100"
    @Published var selectedRateIndex = 0

    func togglePhrase(_ id: String) {
        if expandedPhraseIDs.contains(id) {
            expandedPhraseIDs.remove(id)
        } else {
            expandedPhraseIDs.insert(id)
        }
    }
}
