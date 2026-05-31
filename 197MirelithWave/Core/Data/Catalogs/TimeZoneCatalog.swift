import Foundation

struct CountryTimeZoneInfo: Equatable {
    let country: String
    let timeZoneIdentifier: String
    let utcOffsetHours: Int
}

enum TimeZoneCatalog {
    static let entries: [CountryTimeZoneInfo] = [
        CountryTimeZoneInfo(country: "United States", timeZoneIdentifier: "America/New_York", utcOffsetHours: -5),
        CountryTimeZoneInfo(country: "United Kingdom", timeZoneIdentifier: "Europe/London", utcOffsetHours: 0),
        CountryTimeZoneInfo(country: "France", timeZoneIdentifier: "Europe/Paris", utcOffsetHours: 1),
        CountryTimeZoneInfo(country: "Germany", timeZoneIdentifier: "Europe/Berlin", utcOffsetHours: 1),
        CountryTimeZoneInfo(country: "Italy", timeZoneIdentifier: "Europe/Rome", utcOffsetHours: 1),
        CountryTimeZoneInfo(country: "Spain", timeZoneIdentifier: "Europe/Madrid", utcOffsetHours: 1),
        CountryTimeZoneInfo(country: "Japan", timeZoneIdentifier: "Asia/Tokyo", utcOffsetHours: 9),
        CountryTimeZoneInfo(country: "China", timeZoneIdentifier: "Asia/Shanghai", utcOffsetHours: 8),
        CountryTimeZoneInfo(country: "Australia", timeZoneIdentifier: "Australia/Sydney", utcOffsetHours: 11),
        CountryTimeZoneInfo(country: "Canada", timeZoneIdentifier: "America/Toronto", utcOffsetHours: -5),
        CountryTimeZoneInfo(country: "Brazil", timeZoneIdentifier: "America/Sao_Paulo", utcOffsetHours: -3),
        CountryTimeZoneInfo(country: "Mexico", timeZoneIdentifier: "America/Mexico_City", utcOffsetHours: -6),
        CountryTimeZoneInfo(country: "India", timeZoneIdentifier: "Asia/Kolkata", utcOffsetHours: 5),
        CountryTimeZoneInfo(country: "South Korea", timeZoneIdentifier: "Asia/Seoul", utcOffsetHours: 9),
        CountryTimeZoneInfo(country: "Thailand", timeZoneIdentifier: "Asia/Bangkok", utcOffsetHours: 7),
        CountryTimeZoneInfo(country: "United Arab Emirates", timeZoneIdentifier: "Asia/Dubai", utcOffsetHours: 4),
        CountryTimeZoneInfo(country: "Turkey", timeZoneIdentifier: "Europe/Istanbul", utcOffsetHours: 3),
        CountryTimeZoneInfo(country: "Greece", timeZoneIdentifier: "Europe/Athens", utcOffsetHours: 2),
        CountryTimeZoneInfo(country: "Portugal", timeZoneIdentifier: "Europe/Lisbon", utcOffsetHours: 0),
        CountryTimeZoneInfo(country: "Netherlands", timeZoneIdentifier: "Europe/Amsterdam", utcOffsetHours: 1),
        CountryTimeZoneInfo(country: "Switzerland", timeZoneIdentifier: "Europe/Zurich", utcOffsetHours: 1),
        CountryTimeZoneInfo(country: "Sweden", timeZoneIdentifier: "Europe/Stockholm", utcOffsetHours: 1),
        CountryTimeZoneInfo(country: "Norway", timeZoneIdentifier: "Europe/Oslo", utcOffsetHours: 1),
        CountryTimeZoneInfo(country: "Egypt", timeZoneIdentifier: "Africa/Cairo", utcOffsetHours: 2),
        CountryTimeZoneInfo(country: "South Africa", timeZoneIdentifier: "Africa/Johannesburg", utcOffsetHours: 2),
        CountryTimeZoneInfo(country: "Argentina", timeZoneIdentifier: "America/Argentina/Buenos_Aires", utcOffsetHours: -3),
        CountryTimeZoneInfo(country: "New Zealand", timeZoneIdentifier: "Pacific/Auckland", utcOffsetHours: 13),
        CountryTimeZoneInfo(country: "Singapore", timeZoneIdentifier: "Asia/Singapore", utcOffsetHours: 8),
        CountryTimeZoneInfo(country: "Indonesia", timeZoneIdentifier: "Asia/Jakarta", utcOffsetHours: 7),
        CountryTimeZoneInfo(country: "Vietnam", timeZoneIdentifier: "Asia/Ho_Chi_Minh", utcOffsetHours: 7),
        CountryTimeZoneInfo(country: "Russia", timeZoneIdentifier: "Europe/Moscow", utcOffsetHours: 3),
        CountryTimeZoneInfo(country: "Poland", timeZoneIdentifier: "Europe/Warsaw", utcOffsetHours: 1),
        CountryTimeZoneInfo(country: "Ireland", timeZoneIdentifier: "Europe/Dublin", utcOffsetHours: 0),
        CountryTimeZoneInfo(country: "Czech Republic", timeZoneIdentifier: "Europe/Prague", utcOffsetHours: 1),
        CountryTimeZoneInfo(country: "Austria", timeZoneIdentifier: "Europe/Vienna", utcOffsetHours: 1),
        CountryTimeZoneInfo(country: "Belgium", timeZoneIdentifier: "Europe/Brussels", utcOffsetHours: 1),
        CountryTimeZoneInfo(country: "Denmark", timeZoneIdentifier: "Europe/Copenhagen", utcOffsetHours: 1),
        CountryTimeZoneInfo(country: "Finland", timeZoneIdentifier: "Europe/Helsinki", utcOffsetHours: 2),
        CountryTimeZoneInfo(country: "Morocco", timeZoneIdentifier: "Africa/Casablanca", utcOffsetHours: 1),
        CountryTimeZoneInfo(country: "Israel", timeZoneIdentifier: "Asia/Jerusalem", utcOffsetHours: 2),
        CountryTimeZoneInfo(country: "Philippines", timeZoneIdentifier: "Asia/Manila", utcOffsetHours: 8),
        CountryTimeZoneInfo(country: "Malaysia", timeZoneIdentifier: "Asia/Kuala_Lumpur", utcOffsetHours: 8),
        CountryTimeZoneInfo(country: "Colombia", timeZoneIdentifier: "America/Bogota", utcOffsetHours: -5),
        CountryTimeZoneInfo(country: "Chile", timeZoneIdentifier: "America/Santiago", utcOffsetHours: -4),
        CountryTimeZoneInfo(country: "Peru", timeZoneIdentifier: "America/Lima", utcOffsetHours: -5),
        CountryTimeZoneInfo(country: "Iceland", timeZoneIdentifier: "Atlantic/Reykjavik", utcOffsetHours: 0),
        CountryTimeZoneInfo(country: "Croatia", timeZoneIdentifier: "Europe/Zagreb", utcOffsetHours: 1),
        CountryTimeZoneInfo(country: "Hungary", timeZoneIdentifier: "Europe/Budapest", utcOffsetHours: 1),
        CountryTimeZoneInfo(country: "Romania", timeZoneIdentifier: "Europe/Bucharest", utcOffsetHours: 2)
    ]

    static let homeTimeZones: [(name: String, identifier: String)] = [
        ("New York (UTC-5)", "America/New_York"),
        ("London (UTC+0)", "Europe/London"),
        ("Paris (UTC+1)", "Europe/Paris"),
        ("Berlin (UTC+1)", "Europe/Berlin"),
        ("Tokyo (UTC+9)", "Asia/Tokyo"),
        ("Sydney (UTC+11)", "Australia/Sydney"),
        ("Dubai (UTC+4)", "Asia/Dubai"),
        ("Los Angeles (UTC-8)", "America/Los_Angeles"),
        ("Chicago (UTC-6)", "America/Chicago"),
        ("Moscow (UTC+3)", "Europe/Moscow"),
        ("Singapore (UTC+8)", "Asia/Singapore"),
        ("Mumbai (UTC+5:30)", "Asia/Kolkata")
    ]

    static func info(forCountry country: String) -> CountryTimeZoneInfo? {
        let normalized = country.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return entries.first { $0.country.lowercased() == normalized }
            ?? entries.first { normalized.contains($0.country.lowercased()) || $0.country.lowercased().contains(normalized) }
    }

    static func currentTime(in timeZoneIdentifier: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }

    static func hourDifference(from homeIdentifier: String, to destinationIdentifier: String) -> Int {
        guard let home = TimeZone(identifier: homeIdentifier),
              let dest = TimeZone(identifier: destinationIdentifier) else { return 0 }
        let now = Date()
        let homeOffset = home.secondsFromGMT(for: now)
        let destOffset = dest.secondsFromGMT(for: now)
        return (destOffset - homeOffset) / 3600
    }
}
