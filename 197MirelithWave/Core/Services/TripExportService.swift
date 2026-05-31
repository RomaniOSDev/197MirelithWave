import UIKit

enum TripExportService {
    static func generateText(destination: Destination, bundle: TripBundle, store: AppDataStore) -> String {
        var lines: [String] = []
        lines.append("TRIP SUMMARY")
        lines.append("============")
        lines.append("Destination: \(destination.name)")
        lines.append("Country: \(destination.country)")
        lines.append("Planned: \(formatDate(destination.plannedDate))")
        if let end = bundle.endDate {
            lines.append("Return: \(formatDate(end))")
        }
        if let countdown = TripCountdownHelper.message(for: destination) {
            lines.append(countdown)
        }
        lines.append("")

        if !destination.notes.isEmpty {
            lines.append("Notes: \(destination.notes)")
            lines.append("")
        }

        let packing = bundle.packingItems.sorted { $0.order < $1.order }
        if !packing.isEmpty {
            lines.append("PACKING LIST")
            lines.append("------------")
            for item in packing {
                let mark = item.checked ? "[x]" : "[ ]"
                lines.append("\(mark) \(item.title)")
            }
            lines.append("")
        }

        if !bundle.itineraryDays.isEmpty {
            lines.append("ITINERARY")
            lines.append("---------")
            for day in bundle.itineraryDays.sorted(by: { $0.dayNumber < $1.dayNumber }) {
                lines.append("Day \(day.dayNumber): \(day.title)")
                for activity in day.activities {
                    let time = activity.timeLabel.isEmpty ? "" : "\(activity.timeLabel) — "
                    lines.append("  • \(time)\(activity.title)")
                    if !activity.notes.isEmpty {
                        lines.append("    \(activity.notes)")
                    }
                }
            }
            lines.append("")
        }

        if !bundle.documents.isEmpty {
            lines.append("DOCUMENTS")
            lines.append("---------")
            for doc in bundle.documents {
                let mark = doc.checked ? "[x]" : "[ ]"
                var line = "\(mark) \(doc.title)"
                if let expiry = doc.expiryDate {
                    line += " (expires \(formatDate(expiry)))"
                }
                lines.append(line)
            }
            lines.append("")
        }

        if !bundle.expenses.isEmpty {
            lines.append("BUDGET")
            lines.append("------")
            var total: Double = 0
            for expense in bundle.expenses.sorted(by: { $0.date < $1.date }) {
                lines.append("\(formatDate(expense.date)) — \(expense.category.title): \(expense.currencyCode) \(String(format: "%.2f", expense.amount))")
                if !expense.note.isEmpty {
                    lines.append("  \(expense.note)")
                }
                total += expense.amount
            }
            let currency = bundle.expenses.first?.currencyCode ?? store.baseCurrencyCode
            lines.append("Total: \(currency) \(String(format: "%.2f", total))")
        }

        return lines.joined(separator: "\n")
    }

    static func generatePDF(destination: Destination, bundle: TripBundle, store: AppDataStore) -> URL? {
        let text = generateText(destination: destination, bundle: bundle, store: store)
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let data = renderer.pdfData { context in
            context.beginPage()
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.white
            ]
            let attributed = NSAttributedString(string: text, attributes: attributes)
            let textRect = pageRect.insetBy(dx: 40, dy: 40)
            UIColor(red: 0.616, green: 0.0, blue: 0.051, alpha: 1.0).setFill()
            context.fill(pageRect)
            attributed.draw(in: textRect)
        }

        let fileName = "trip_\(destination.name.replacingOccurrences(of: " ", with: "_")).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

enum TripCountdownHelper {
    static func daysUntil(_ date: Date) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: start, to: target).day ?? 0
    }

    static func message(for destination: Destination) -> String? {
        guard !destination.visited else { return nil }
        let days = daysUntil(destination.plannedDate)
        if days > 0 {
            return "\(days) day\(days == 1 ? "" : "s") until departure"
        } else if days == 0 {
            return "Departure is today!"
        } else {
            return "Trip started \(abs(days)) day\(abs(days) == 1 ? "" : "s") ago"
        }
    }
}
