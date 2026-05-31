import Combine
import Foundation

final class AppDataStore: ObservableObject {
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let destinations = "destinations"
        static let lastVisited = "lastVisited"
        static let tripItems = "tripItems"
        static let tripBundles = "tripBundles"
        static let lastClearedAt = "lastClearedAt"
        static let baseCurrencyCode = "baseCurrencyCode"
        static let homeTimeZoneIdentifier = "homeTimeZoneIdentifier"
        static let selectedPhrases = "selectedPhrases"
        static let currencyRatesTable = "currencyRatesTable"
        static let destinationsAdded = "destinationsAdded"
        static let tripsCompleted = "tripsCompleted"
        static let checklistsCompleted = "checklistsCompleted"
        static let conversionsRun = "conversionsRun"
        static let phrasesViewed = "phrasesViewed"
        static let viewedPhraseIDs = "viewedPhraseIDs"
        static let itineraryDaysAdded = "itineraryDaysAdded"
        static let budgetEntriesAdded = "budgetEntriesAdded"
        static let documentsCompletedCount = "documentsCompletedCount"
        static let emergencyInfoViewed = "emergencyInfoViewed"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private var sessionStartDate: Date?
    private var cancellables = Set<AnyCancellable>()

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }

    @Published var lastActivityDate: Date? {
        didSet {
            if let date = lastActivityDate {
                defaults.set(date, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }

    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveDictionary(achievementsUnlocked, forKey: Keys.achievementsUnlocked) }
    }

    @Published var destinations: [Destination] {
        didSet { save(destinations, forKey: Keys.destinations) }
    }

    @Published var lastVisited: String? {
        didSet {
            if let value = lastVisited {
                defaults.set(value, forKey: Keys.lastVisited)
            } else {
                defaults.removeObject(forKey: Keys.lastVisited)
            }
        }
    }

    @Published var tripBundles: [UUID: TripBundle] {
        didSet { saveTripBundles() }
    }

    @Published var lastClearedAt: Date? {
        didSet {
            if let date = lastClearedAt {
                defaults.set(date, forKey: Keys.lastClearedAt)
            } else {
                defaults.removeObject(forKey: Keys.lastClearedAt)
            }
        }
    }

    @Published var baseCurrencyCode: String {
        didSet {
            defaults.set(baseCurrencyCode, forKey: Keys.baseCurrencyCode)
            refreshCurrencyRates()
        }
    }

    @Published var homeTimeZoneIdentifier: String {
        didSet { defaults.set(homeTimeZoneIdentifier, forKey: Keys.homeTimeZoneIdentifier) }
    }

    @Published var selectedPhrases: [String] {
        didSet { save(selectedPhrases, forKey: Keys.selectedPhrases) }
    }

    @Published var currencyRatesTable: [CurrencyRate] {
        didSet { save(currencyRatesTable, forKey: Keys.currencyRatesTable) }
    }

    @Published var destinationsAdded: Int {
        didSet { defaults.set(destinationsAdded, forKey: Keys.destinationsAdded) }
    }

    @Published var tripsCompleted: Int {
        didSet { defaults.set(tripsCompleted, forKey: Keys.tripsCompleted) }
    }

    @Published var checklistsCompleted: Int {
        didSet { defaults.set(checklistsCompleted, forKey: Keys.checklistsCompleted) }
    }

    @Published var conversionsRun: Int {
        didSet { defaults.set(conversionsRun, forKey: Keys.conversionsRun) }
    }

    @Published var phrasesViewed: Int {
        didSet { defaults.set(phrasesViewed, forKey: Keys.phrasesViewed) }
    }

    @Published var itineraryDaysAdded: Int {
        didSet { defaults.set(itineraryDaysAdded, forKey: Keys.itineraryDaysAdded) }
    }

    @Published var budgetEntriesAdded: Int {
        didSet { defaults.set(budgetEntriesAdded, forKey: Keys.budgetEntriesAdded) }
    }

    @Published var documentsCompletedCount: Int {
        didSet { defaults.set(documentsCompletedCount, forKey: Keys.documentsCompletedCount) }
    }

    @Published var emergencyInfoViewed: Int {
        didSet { defaults.set(emergencyInfoViewed, forKey: Keys.emergencyInfoViewed) }
    }

    @Published private(set) var viewedPhraseIDs: Set<String> {
        didSet { save(Array(viewedPhraseIDs), forKey: Keys.viewedPhraseIDs) }
    }

    @Published var pendingAchievementUnlocks: [Achievement] = []

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadDictionary(forKey: Keys.achievementsUnlocked, defaults: defaults)
        destinations = Self.load([Destination].self, forKey: Keys.destinations, defaults: defaults) ?? []
        lastVisited = defaults.string(forKey: Keys.lastVisited)
        tripBundles = Self.loadTripBundles(forKey: Keys.tripBundles, defaults: defaults)
        lastClearedAt = defaults.object(forKey: Keys.lastClearedAt) as? Date
        baseCurrencyCode = defaults.string(forKey: Keys.baseCurrencyCode) ?? ""
        homeTimeZoneIdentifier = defaults.string(forKey: Keys.homeTimeZoneIdentifier) ?? "America/New_York"
        selectedPhrases = Self.load([String].self, forKey: Keys.selectedPhrases, defaults: defaults) ?? []
        currencyRatesTable = Self.load([CurrencyRate].self, forKey: Keys.currencyRatesTable, defaults: defaults) ?? []
        destinationsAdded = defaults.integer(forKey: Keys.destinationsAdded)
        tripsCompleted = defaults.integer(forKey: Keys.tripsCompleted)
        checklistsCompleted = defaults.integer(forKey: Keys.checklistsCompleted)
        conversionsRun = defaults.integer(forKey: Keys.conversionsRun)
        phrasesViewed = defaults.integer(forKey: Keys.phrasesViewed)
        itineraryDaysAdded = defaults.integer(forKey: Keys.itineraryDaysAdded)
        budgetEntriesAdded = defaults.integer(forKey: Keys.budgetEntriesAdded)
        documentsCompletedCount = defaults.integer(forKey: Keys.documentsCompletedCount)
        emergencyInfoViewed = defaults.integer(forKey: Keys.emergencyInfoViewed)
        let storedPhraseIDs = Self.load([String].self, forKey: Keys.viewedPhraseIDs, defaults: defaults) ?? []
        viewedPhraseIDs = Set(storedPhraseIDs)

        migrateLegacyTripItems(defaults: defaults)

        if currencyRatesTable.isEmpty && !baseCurrencyCode.isEmpty {
            refreshCurrencyRates()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataReset),
            name: .dataReset,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Computed Stats

    var mostPlannedCountry: String {
        let counts = Dictionary(grouping: destinations, by: \.country).mapValues(\.count)
        return counts.max(by: { $0.value < $1.value })?.key ?? "—"
    }

    var longestChecklistCount: Int {
        tripBundles.values.map(\.packingItems.count).max() ?? 0
    }

    var tripsThisYear: Int {
        let year = Calendar.current.component(.year, from: Date())
        return destinations.filter {
            Calendar.current.component(.year, from: $0.plannedDate) == year
        }.count
    }

    var totalItineraryDays: Int {
        tripBundles.values.reduce(0) { $0 + $1.itineraryDays.count }
    }

    var totalBudgetEntries: Int {
        tripBundles.values.reduce(0) { $0 + $1.expenses.count }
    }

    // MARK: - Session

    func recordMeaningfulAction() {
        totalSessionsCompleted += 1
        updateStreak()
        evaluateAchievements()
    }

    func startSessionTracking() {
        sessionStartDate = Date()
    }

    func pauseSessionTracking() {
        guard let start = sessionStartDate else { return }
        let elapsed = Int(Date().timeIntervalSince(start) / 60)
        if elapsed > 0 {
            totalMinutesUsed += elapsed
        }
        sessionStartDate = nil
    }

    // MARK: - Destinations

    func addDestination(_ destination: Destination) {
        destinations.append(destination)
        destinationsAdded += 1
        var bundle = TripBundle(destinationID: destination.id, endDate: destination.endDate)
        bundle = seedDefaultDocuments(into: bundle)
        tripBundles[destination.id] = bundle
        recordMeaningfulAction()
    }

    func updateDestination(_ destination: Destination) {
        guard let index = destinations.firstIndex(where: { $0.id == destination.id }) else { return }
        let wasVisited = destinations[index].visited
        destinations[index] = destination
        var bundle = tripBundle(for: destination.id)
        bundle.endDate = destination.endDate
        tripBundles[destination.id] = bundle
        if destination.visited && !wasVisited {
            markTripCompleted(name: destination.name)
        }
    }

    func deleteDestination(_ destination: Destination) {
        destinations.removeAll { $0.id == destination.id }
        tripBundles.removeValue(forKey: destination.id)
    }

    func duplicateDestination(from sourceID: UUID, to targetID: UUID) {
        guard let source = tripBundles[sourceID] else { return }
        var target = tripBundle(for: targetID)
        let maxOrder = target.packingItems.map(\.order).max() ?? -1
        let copied = source.packingItems.enumerated().map { index, item in
            ChecklistItem(title: item.title, checked: false, order: maxOrder + 1 + index)
        }
        target.packingItems.append(contentsOf: copied)
        tripBundles[targetID] = target
        recordMeaningfulAction()
    }

    func markTripCompleted(name: String) {
        tripsCompleted += 1
        lastVisited = name
        recordMeaningfulAction()
    }

    func toggleDestinationVisited(_ destination: Destination) {
        var updated = destination
        updated.visited.toggle()
        updateDestination(updated)
    }

    func destination(for id: UUID) -> Destination? {
        destinations.first { $0.id == id }
    }

    // MARK: - Trip Bundles

    func tripBundle(for destinationID: UUID) -> TripBundle {
        if let existing = tripBundles[destinationID] {
            return existing
        }
        let bundle = seedDefaultDocuments(into: TripBundle(destinationID: destinationID))
        tripBundles[destinationID] = bundle
        return bundle
    }

    func updateTripBundle(_ bundle: TripBundle) {
        tripBundles[bundle.destinationID] = bundle
    }

    private func seedDefaultDocuments(into bundle: TripBundle) -> TripBundle {
        var updated = bundle
        if updated.documents.isEmpty {
            updated.documents = [
                TravelDocument(title: "Passport"),
                TravelDocument(title: "Visa"),
                TravelDocument(title: "Travel Insurance"),
                TravelDocument(title: "Boarding Pass")
            ]
        }
        return updated
    }

    // MARK: - Packing

    func sortedPackingItems(for destinationID: UUID) -> [ChecklistItem] {
        tripBundle(for: destinationID).packingItems.sorted { $0.order < $1.order }
    }

    func addPackingItem(destinationID: UUID, title: String) {
        var bundle = tripBundle(for: destinationID)
        let order = (bundle.packingItems.map(\.order).max() ?? -1) + 1
        bundle.packingItems.append(ChecklistItem(title: title, order: order))
        tripBundles[destinationID] = bundle
        recordMeaningfulAction()
    }

    func updatePackingItem(destinationID: UUID, item: ChecklistItem) {
        var bundle = tripBundle(for: destinationID)
        guard let index = bundle.packingItems.firstIndex(where: { $0.id == item.id }) else { return }
        bundle.packingItems[index] = item
        tripBundles[destinationID] = bundle
    }

    func deletePackingItem(destinationID: UUID, item: ChecklistItem) {
        var bundle = tripBundle(for: destinationID)
        bundle.packingItems.removeAll { $0.id == item.id }
        tripBundles[destinationID] = bundle
    }

    func togglePackingItem(destinationID: UUID, item: ChecklistItem) {
        var bundle = tripBundle(for: destinationID)
        guard let index = bundle.packingItems.firstIndex(where: { $0.id == item.id }) else { return }
        bundle.packingItems[index].checked.toggle()
        tripBundles[destinationID] = bundle
        if bundle.packingItems[index].checked {
            recordMeaningfulAction()
        }
    }

    func movePackingItems(destinationID: UUID, from source: IndexSet, to destination: Int) {
        var bundle = tripBundle(for: destinationID)
        var sorted = bundle.packingItems.sorted { $0.order < $1.order }
        let movingItems = source.sorted().map { sorted[$0] }
        var remaining = sorted.enumerated().filter { !source.contains($0.offset) }.map(\.element)
        let insertIndex = min(max(destination - source.filter { $0 < destination }.count, 0), remaining.count)
        remaining.insert(contentsOf: movingItems, at: insertIndex)
        for index in remaining.indices {
            remaining[index].order = index
        }
        bundle.packingItems = remaining
        tripBundles[destinationID] = bundle
    }

    func clearCompletedPackingItems(destinationID: UUID) {
        var bundle = tripBundle(for: destinationID)
        let completedCount = bundle.packingItems.filter(\.checked).count
        guard completedCount > 0 else { return }
        bundle.packingItems.removeAll { $0.checked }
        tripBundles[destinationID] = bundle
        lastClearedAt = Date()
        checklistsCompleted += 1
        recordMeaningfulAction()
    }

    func applyPackingTemplate(destinationID: UUID, template: PackingTemplate) {
        var bundle = tripBundle(for: destinationID)
        let maxOrder = bundle.packingItems.map(\.order).max() ?? -1
        let existingTitles = Set(bundle.packingItems.map { $0.title.lowercased() })
        var nextOrder = maxOrder + 1
        for title in template.items where !existingTitles.contains(title.lowercased()) {
            bundle.packingItems.append(ChecklistItem(title: title, order: nextOrder))
            nextOrder += 1
        }
        tripBundles[destinationID] = bundle
        recordMeaningfulAction()
    }

    // MARK: - Itinerary

    func addItineraryDay(destinationID: UUID, title: String) {
        var bundle = tripBundle(for: destinationID)
        let dayNumber = (bundle.itineraryDays.map(\.dayNumber).max() ?? 0) + 1
        bundle.itineraryDays.append(ItineraryDay(dayNumber: dayNumber, title: title))
        tripBundles[destinationID] = bundle
        itineraryDaysAdded += 1
        recordMeaningfulAction()
    }

    func updateItineraryDay(destinationID: UUID, day: ItineraryDay) {
        var bundle = tripBundle(for: destinationID)
        guard let index = bundle.itineraryDays.firstIndex(where: { $0.id == day.id }) else { return }
        bundle.itineraryDays[index] = day
        tripBundles[destinationID] = bundle
    }

    func deleteItineraryDay(destinationID: UUID, day: ItineraryDay) {
        var bundle = tripBundle(for: destinationID)
        bundle.itineraryDays.removeAll { $0.id == day.id }
        tripBundles[destinationID] = bundle
    }

    func addItineraryActivity(destinationID: UUID, dayID: UUID, activity: ItineraryActivity) {
        var bundle = tripBundle(for: destinationID)
        guard let index = bundle.itineraryDays.firstIndex(where: { $0.id == dayID }) else { return }
        bundle.itineraryDays[index].activities.append(activity)
        tripBundles[destinationID] = bundle
        recordMeaningfulAction()
    }

    // MARK: - Documents

    func toggleDocument(destinationID: UUID, document: TravelDocument) {
        var bundle = tripBundle(for: destinationID)
        guard let index = bundle.documents.firstIndex(where: { $0.id == document.id }) else { return }
        let wasAllChecked = !bundle.documents.isEmpty && bundle.documents.allSatisfy(\.checked)
        bundle.documents[index].checked.toggle()
        tripBundles[destinationID] = bundle
        checkDocumentsCompletion(bundle: bundle, wasAllChecked: wasAllChecked)
        recordMeaningfulAction()
    }

    func updateDocument(destinationID: UUID, document: TravelDocument) {
        var bundle = tripBundle(for: destinationID)
        guard let index = bundle.documents.firstIndex(where: { $0.id == document.id }) else { return }
        let wasAllChecked = !bundle.documents.isEmpty && bundle.documents.allSatisfy(\.checked)
        bundle.documents[index] = document
        tripBundles[destinationID] = bundle
        checkDocumentsCompletion(bundle: bundle, wasAllChecked: wasAllChecked)
    }

    func addDocument(destinationID: UUID, title: String, expiryDate: Date?) {
        var bundle = tripBundle(for: destinationID)
        bundle.documents.append(TravelDocument(title: title, expiryDate: expiryDate))
        tripBundles[destinationID] = bundle
        recordMeaningfulAction()
    }

    func documentsWithExpiryWarning(for destination: Destination) -> [TravelDocument] {
        let bundle = tripBundle(for: destination.id)
        let tripStart = destination.plannedDate
        return bundle.documents.filter { doc in
            guard let expiry = doc.expiryDate else { return false }
            let daysBefore = Calendar.current.dateComponents([.day], from: Date(), to: expiry).day ?? 999
            let expiresBeforeTrip = expiry < tripStart
            return daysBefore <= 90 || expiresBeforeTrip
        }
    }

    private func checkDocumentsCompletion(bundle: TripBundle, wasAllChecked: Bool) {
        let allChecked = !bundle.documents.isEmpty && bundle.documents.allSatisfy(\.checked)
        guard allChecked && !wasAllChecked else { return }
        documentsCompletedCount += 1
        evaluateAchievements()
    }

    // MARK: - Budget

    func addExpense(destinationID: UUID, expense: TripExpense) {
        var bundle = tripBundle(for: destinationID)
        bundle.expenses.append(expense)
        tripBundles[destinationID] = bundle
        budgetEntriesAdded += 1
        recordMeaningfulAction()
    }

    func deleteExpense(destinationID: UUID, expense: TripExpense) {
        var bundle = tripBundle(for: destinationID)
        bundle.expenses.removeAll { $0.id == expense.id }
        tripBundles[destinationID] = bundle
    }

    func totalExpenses(for destinationID: UUID, convertedTo baseCode: String) -> Double {
        let bundle = tripBundle(for: destinationID)
        let rates = CurrencyCatalog.rates(relativeTo: baseCode.isEmpty ? "USD" : baseCode)
        return bundle.expenses.reduce(0) { partial, expense in
            let rate = rates.first(where: { $0.code == expense.currencyCode })?.rate ?? 1.0
            return partial + expense.amount / rate
        }
    }

    // MARK: - Essentials

    func setBaseCurrency(_ code: String) {
        baseCurrencyCode = code
        refreshCurrencyRates()
        recordMeaningfulAction()
    }

    func refreshCurrencyRates() {
        guard !baseCurrencyCode.isEmpty else {
            currencyRatesTable = []
            return
        }
        currencyRatesTable = CurrencyCatalog.rates(relativeTo: baseCurrencyCode)
    }

    func recordConversion() {
        conversionsRun += 1
        recordMeaningfulAction()
    }

    func recordPhraseViewed(_ phraseID: String) {
        guard !viewedPhraseIDs.contains(phraseID) else { return }
        viewedPhraseIDs.insert(phraseID)
        phrasesViewed += 1
        recordMeaningfulAction()
    }

    func recordEmergencyInfoViewed() {
        emergencyInfoViewed += 1
        recordMeaningfulAction()
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
    }

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        reloadFromDefaults()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    func isAchievementUnlocked(_ id: String) -> Bool {
        achievementsUnlocked[id] != nil
    }

    func unlockedAchievementCount() -> Int {
        achievementsUnlocked.count
    }

    // MARK: - Private

    private func migrateLegacyTripItems(defaults: UserDefaults) {
        guard tripBundles.isEmpty,
              let legacyItems = Self.load([ChecklistItem].self, forKey: Keys.tripItems, defaults: defaults),
              !legacyItems.isEmpty else { return }

        if let firstDestination = destinations.first {
            var bundle = TripBundle(destinationID: firstDestination.id, packingItems: legacyItems)
            bundle = seedDefaultDocuments(into: bundle)
            tripBundles[firstDestination.id] = bundle
        }
        defaults.removeObject(forKey: Keys.tripItems)
    }

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            let dayDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if dayDiff == 1 {
                streakDays += 1
            } else if dayDiff > 1 {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }

        lastActivityDate = Date()
    }

    private func evaluateAchievements() {
        var newlyUnlocked: [Achievement] = []
        for achievement in Achievement.all {
            guard achievementsUnlocked[achievement.id] == nil else { continue }
            if achievement.condition(self) {
                achievementsUnlocked[achievement.id] = Date()
                newlyUnlocked.append(achievement)
            }
        }
        if !newlyUnlocked.isEmpty {
            pendingAchievementUnlocks.append(contentsOf: newlyUnlocked)
            NotificationCenter.default.post(name: .achievementUnlocked, object: newlyUnlocked)
        }
    }

    @objc private func handleDataReset() {
        reloadFromDefaults()
    }

    private func reloadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadDictionary(forKey: Keys.achievementsUnlocked, defaults: defaults)
        destinations = Self.load([Destination].self, forKey: Keys.destinations, defaults: defaults) ?? []
        lastVisited = defaults.string(forKey: Keys.lastVisited)
        tripBundles = Self.loadTripBundles(forKey: Keys.tripBundles, defaults: defaults)
        lastClearedAt = defaults.object(forKey: Keys.lastClearedAt) as? Date
        baseCurrencyCode = defaults.string(forKey: Keys.baseCurrencyCode) ?? ""
        homeTimeZoneIdentifier = defaults.string(forKey: Keys.homeTimeZoneIdentifier) ?? "America/New_York"
        selectedPhrases = Self.load([String].self, forKey: Keys.selectedPhrases, defaults: defaults) ?? []
        currencyRatesTable = Self.load([CurrencyRate].self, forKey: Keys.currencyRatesTable, defaults: defaults) ?? []
        destinationsAdded = defaults.integer(forKey: Keys.destinationsAdded)
        tripsCompleted = defaults.integer(forKey: Keys.tripsCompleted)
        checklistsCompleted = defaults.integer(forKey: Keys.checklistsCompleted)
        conversionsRun = defaults.integer(forKey: Keys.conversionsRun)
        phrasesViewed = defaults.integer(forKey: Keys.phrasesViewed)
        itineraryDaysAdded = defaults.integer(forKey: Keys.itineraryDaysAdded)
        budgetEntriesAdded = defaults.integer(forKey: Keys.budgetEntriesAdded)
        documentsCompletedCount = defaults.integer(forKey: Keys.documentsCompletedCount)
        emergencyInfoViewed = defaults.integer(forKey: Keys.emergencyInfoViewed)
        let storedPhraseIDs = Self.load([String].self, forKey: Keys.viewedPhraseIDs, defaults: defaults) ?? []
        viewedPhraseIDs = Set(storedPhraseIDs)
        pendingAchievementUnlocks = []
    }

    private func saveTripBundles() {
        let keyed = Dictionary(uniqueKeysWithValues: tripBundles.map { ($0.key.uuidString, $0.value) })
        save(keyed, forKey: Keys.tripBundles)
    }

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private func saveDictionary(_ value: [String: Date], forKey key: String) {
        let stringKeyed = value.mapValues { $0.timeIntervalSince1970 }
        if let data = try? encoder.encode(stringKeyed) {
            defaults.set(data, forKey: key)
        }
    }

    private static func load<T: Decodable>(_ type: T.Type, forKey key: String, defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private static func loadTripBundles(forKey key: String, defaults: UserDefaults) -> [UUID: TripBundle] {
        guard let data = defaults.data(forKey: key),
              let raw = try? JSONDecoder().decode([String: TripBundle].self, from: data) else {
            return [:]
        }
        var result: [UUID: TripBundle] = [:]
        for (key, bundle) in raw {
            if let uuid = UUID(uuidString: key) {
                result[uuid] = bundle
            }
        }
        return result
    }

    private static func loadDictionary(forKey key: String, defaults: UserDefaults) -> [String: Date] {
        guard let data = defaults.data(forKey: key),
              let raw = try? JSONDecoder().decode([String: Double].self, from: data) else {
            return [:]
        }
        return raw.mapValues { Date(timeIntervalSince1970: $0) }
    }
}
