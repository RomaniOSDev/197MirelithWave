import Foundation

struct EmergencyInfo: Identifiable, Equatable {
    var id: String { country }
    let country: String
    let emergencyNumber: String
    let embassyNote: String
    let drivingSide: String
}

enum EmergencyInfoCatalog {
    static let entries: [EmergencyInfo] = [
        EmergencyInfo(country: "United States", emergencyNumber: "911", embassyNote: "Contact your embassy for passport emergencies.", drivingSide: "Right"),
        EmergencyInfo(country: "United Kingdom", emergencyNumber: "999", embassyNote: "Register with your embassy before long stays.", drivingSide: "Left"),
        EmergencyInfo(country: "France", emergencyNumber: "112", embassyNote: "EU emergency number works across Europe.", drivingSide: "Right"),
        EmergencyInfo(country: "Germany", emergencyNumber: "112", embassyNote: "Police: 110, Medical/Fire: 112.", drivingSide: "Right"),
        EmergencyInfo(country: "Italy", emergencyNumber: "112", embassyNote: "Carabinieri assist tourists in cities.", drivingSide: "Right"),
        EmergencyInfo(country: "Spain", emergencyNumber: "112", embassyNote: "Tourist helplines available in major cities.", drivingSide: "Right"),
        EmergencyInfo(country: "Japan", emergencyNumber: "110 / 119", embassyNote: "Police: 110, Fire/Ambulance: 119.", drivingSide: "Left"),
        EmergencyInfo(country: "China", emergencyNumber: "110 / 120", embassyNote: "Police: 110, Ambulance: 120.", drivingSide: "Right"),
        EmergencyInfo(country: "Australia", emergencyNumber: "000", embassyNote: "Triple zero for all emergencies.", drivingSide: "Left"),
        EmergencyInfo(country: "Canada", emergencyNumber: "911", embassyNote: "Same as US emergency services.", drivingSide: "Right"),
        EmergencyInfo(country: "Brazil", emergencyNumber: "190 / 192", embassyNote: "Police: 190, Ambulance: 192.", drivingSide: "Right"),
        EmergencyInfo(country: "Mexico", emergencyNumber: "911", embassyNote: "Unified emergency number nationwide.", drivingSide: "Right"),
        EmergencyInfo(country: "India", emergencyNumber: "112", embassyNote: "Single emergency number across India.", drivingSide: "Left"),
        EmergencyInfo(country: "South Korea", emergencyNumber: "112 / 119", embassyNote: "Police: 112, Fire/Ambulance: 119.", drivingSide: "Right"),
        EmergencyInfo(country: "Thailand", emergencyNumber: "191 / 1669", embassyNote: "Tourist police: 1155 in major areas.", drivingSide: "Left"),
        EmergencyInfo(country: "United Arab Emirates", emergencyNumber: "999", embassyNote: "English-speaking operators available.", drivingSide: "Right"),
        EmergencyInfo(country: "Turkey", emergencyNumber: "112", embassyNote: "Single number for all emergencies.", drivingSide: "Right"),
        EmergencyInfo(country: "Greece", emergencyNumber: "112", embassyNote: "EU standard emergency number.", drivingSide: "Right"),
        EmergencyInfo(country: "Portugal", emergencyNumber: "112", embassyNote: "EU standard emergency number.", drivingSide: "Right"),
        EmergencyInfo(country: "Netherlands", emergencyNumber: "112", embassyNote: "EU standard emergency number.", drivingSide: "Right"),
        EmergencyInfo(country: "Switzerland", emergencyNumber: "112", embassyNote: "Police: 117, Fire: 118, Ambulance: 144.", drivingSide: "Right"),
        EmergencyInfo(country: "Sweden", emergencyNumber: "112", embassyNote: "EU standard emergency number.", drivingSide: "Right"),
        EmergencyInfo(country: "Norway", emergencyNumber: "112 / 113", embassyNote: "Police: 112, Medical: 113.", drivingSide: "Right"),
        EmergencyInfo(country: "Egypt", emergencyNumber: "122 / 123", embassyNote: "Police: 122, Ambulance: 123.", drivingSide: "Right"),
        EmergencyInfo(country: "South Africa", emergencyNumber: "10111", embassyNote: "Police emergency line.", drivingSide: "Left"),
        EmergencyInfo(country: "Argentina", emergencyNumber: "911", embassyNote: "Unified emergency number.", drivingSide: "Right"),
        EmergencyInfo(country: "New Zealand", emergencyNumber: "111", embassyNote: "Single number for all services.", drivingSide: "Left"),
        EmergencyInfo(country: "Singapore", emergencyNumber: "999", embassyNote: "Police and ambulance services.", drivingSide: "Left"),
        EmergencyInfo(country: "Indonesia", emergencyNumber: "112", embassyNote: "National emergency call center.", drivingSide: "Left"),
        EmergencyInfo(country: "Vietnam", emergencyNumber: "113 / 115", embassyNote: "Police: 113, Ambulance: 115.", drivingSide: "Right"),
        EmergencyInfo(country: "Russia", emergencyNumber: "112", embassyNote: "Unified emergency number.", drivingSide: "Right"),
        EmergencyInfo(country: "Poland", emergencyNumber: "112", embassyNote: "EU standard emergency number.", drivingSide: "Right"),
        EmergencyInfo(country: "Ireland", emergencyNumber: "112 / 999", embassyNote: "Both numbers work nationwide.", drivingSide: "Left"),
        EmergencyInfo(country: "Czech Republic", emergencyNumber: "112", embassyNote: "EU standard emergency number.", drivingSide: "Right"),
        EmergencyInfo(country: "Austria", emergencyNumber: "112", embassyNote: "EU standard emergency number.", drivingSide: "Right"),
        EmergencyInfo(country: "Belgium", emergencyNumber: "112", embassyNote: "EU standard emergency number.", drivingSide: "Right"),
        EmergencyInfo(country: "Denmark", emergencyNumber: "112", embassyNote: "EU standard emergency number.", drivingSide: "Right"),
        EmergencyInfo(country: "Finland", emergencyNumber: "112", embassyNote: "EU standard emergency number.", drivingSide: "Right"),
        EmergencyInfo(country: "Morocco", emergencyNumber: "19 / 15", embassyNote: "Police: 19, Ambulance: 15.", drivingSide: "Right"),
        EmergencyInfo(country: "Israel", emergencyNumber: "100 / 101", embassyNote: "Police: 100, Ambulance: 101.", drivingSide: "Right"),
        EmergencyInfo(country: "Philippines", emergencyNumber: "911", embassyNote: "National emergency hotline.", drivingSide: "Right"),
        EmergencyInfo(country: "Malaysia", emergencyNumber: "999", embassyNote: "All emergency services.", drivingSide: "Left"),
        EmergencyInfo(country: "Colombia", emergencyNumber: "123", embassyNote: "Unified emergency line.", drivingSide: "Right"),
        EmergencyInfo(country: "Chile", emergencyNumber: "131 / 133", embassyNote: "Ambulance: 131, Fire: 133.", drivingSide: "Right"),
        EmergencyInfo(country: "Peru", emergencyNumber: "105 / 116", embassyNote: "Police: 105, Fire: 116.", drivingSide: "Right"),
        EmergencyInfo(country: "Iceland", emergencyNumber: "112", embassyNote: "Single number for all emergencies.", drivingSide: "Right"),
        EmergencyInfo(country: "Croatia", emergencyNumber: "112", embassyNote: "EU standard emergency number.", drivingSide: "Right"),
        EmergencyInfo(country: "Hungary", emergencyNumber: "112", embassyNote: "EU standard emergency number.", drivingSide: "Right"),
        EmergencyInfo(country: "Romania", emergencyNumber: "112", embassyNote: "EU standard emergency number.", drivingSide: "Right")
    ]

    static func info(forCountry country: String) -> EmergencyInfo? {
        let normalized = country.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return entries.first { $0.country.lowercased() == normalized }
            ?? entries.first { normalized.contains($0.country.lowercased()) || $0.country.lowercased().contains(normalized) }
    }
}
