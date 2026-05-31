import Foundation

struct CurrencyRate: Identifiable, Codable, Equatable {
    var id: String { code }
    var code: String
    var name: String
    var symbol: String
    var rate: Double
}

struct TravelPhrase: Identifiable, Equatable {
    let id: String
    let english: String
    let spanish: String
    let french: String
    let german: String
    let italian: String
}

enum CurrencyCatalog {
    static let defaultRates: [CurrencyRate] = [
        CurrencyRate(code: "USD", name: "US Dollar", symbol: "$", rate: 1.0),
        CurrencyRate(code: "EUR", name: "Euro", symbol: "€", rate: 0.92),
        CurrencyRate(code: "GBP", name: "British Pound", symbol: "£", rate: 0.79),
        CurrencyRate(code: "JPY", name: "Japanese Yen", symbol: "¥", rate: 149.5),
        CurrencyRate(code: "CAD", name: "Canadian Dollar", symbol: "C$", rate: 1.36),
        CurrencyRate(code: "AUD", name: "Australian Dollar", symbol: "A$", rate: 1.53),
        CurrencyRate(code: "CHF", name: "Swiss Franc", symbol: "Fr", rate: 0.88),
        CurrencyRate(code: "CNY", name: "Chinese Yuan", symbol: "¥", rate: 7.24),
        CurrencyRate(code: "MXN", name: "Mexican Peso", symbol: "$", rate: 17.15),
        CurrencyRate(code: "BRL", name: "Brazilian Real", symbol: "R$", rate: 4.97),
        CurrencyRate(code: "INR", name: "Indian Rupee", symbol: "₹", rate: 83.1),
        CurrencyRate(code: "KRW", name: "South Korean Won", symbol: "₩", rate: 1320.0)
    ]

    static func rates(relativeTo baseCode: String) -> [CurrencyRate] {
        guard let base = defaultRates.first(where: { $0.code == baseCode }) else {
            return defaultRates
        }
        return defaultRates.map { currency in
            let convertedRate = currency.rate / base.rate
            return CurrencyRate(
                code: currency.code,
                name: currency.name,
                symbol: currency.symbol,
                rate: convertedRate
            )
        }
    }
}

enum PhraseCatalog {
    static let phrases: [TravelPhrase] = [
        TravelPhrase(id: "hello", english: "Hello", spanish: "Hola", french: "Bonjour", german: "Hallo", italian: "Ciao"),
        TravelPhrase(id: "thanks", english: "Thank you", spanish: "Gracias", french: "Merci", german: "Danke", italian: "Grazie"),
        TravelPhrase(id: "please", english: "Please", spanish: "Por favor", french: "S'il vous plaît", german: "Bitte", italian: "Per favore"),
        TravelPhrase(id: "excuse", english: "Excuse me", spanish: "Disculpe", french: "Excusez-moi", german: "Entschuldigung", italian: "Mi scusi"),
        TravelPhrase(id: "yes", english: "Yes", spanish: "Sí", french: "Oui", german: "Ja", italian: "Sì"),
        TravelPhrase(id: "no", english: "No", spanish: "No", french: "Non", german: "Nein", italian: "No"),
        TravelPhrase(id: "help", english: "I need help", spanish: "Necesito ayuda", french: "J'ai besoin d'aide", german: "Ich brauche Hilfe", italian: "Ho bisogno di aiuto"),
        TravelPhrase(id: "water", english: "Water, please", spanish: "Agua, por favor", french: "De l'eau, s'il vous plaît", german: "Wasser, bitte", italian: "Acqua, per favore"),
        TravelPhrase(id: "bill", english: "The bill, please", spanish: "La cuenta, por favor", french: "L'addition, s'il vous plaît", german: "Die Rechnung, bitte", italian: "Il conto, per favore"),
        TravelPhrase(id: "where", english: "Where is...?", spanish: "¿Dónde está...?", french: "Où est...?", german: "Wo ist...?", italian: "Dove si trova...?"),
        TravelPhrase(id: "howmuch", english: "How much does it cost?", spanish: "¿Cuánto cuesta?", french: "Combien ça coûte?", german: "Wie viel kostet das?", italian: "Quanto costa?"),
        TravelPhrase(id: "bathroom", english: "Where is the bathroom?", spanish: "¿Dónde está el baño?", french: "Où sont les toilettes?", german: "Wo ist die Toilette?", italian: "Dov'è il bagno?")
    ]
}
