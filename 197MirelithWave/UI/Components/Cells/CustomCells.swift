import SwiftUI

struct DestinationCell: View {
    let destination: Destination
    let itemCount: Int
    let itineraryDays: Int
    let packingProgress: Double
    var isPulsing: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                AppProgressRing(progress: destination.visited ? 1 : packingProgress, lineWidth: 3)
                    .frame(width: 52, height: 52)
                AppIconBadge(
                    iconName: destination.visited ? "checkmark" : "airplane",
                    size: 40,
                    iconSize: 16,
                    style: destination.visited ? .success : .primary
                )
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(destination.name)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .strikethrough(destination.visited)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Spacer(minLength: 4)
                    if destination.visited {
                        AppTagPill(text: "Visited", style: .accent)
                    }
                }

                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color("AppAccent"))
                    Text(destination.country)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                HStack(spacing: 6) {
                    AppTagPill(text: destination.plannedDate.formatted(date: .abbreviated, time: .omitted), style: .muted)
                    if itemCount > 0 {
                        AppTagPill(text: "\(itemCount) items", style: .primary)
                    }
                    if itineraryDays > 0 {
                        AppTagPill(text: "\(itineraryDays)d plan", style: .accent)
                    }
                }

                if let countdown = TripCountdownHelper.message(for: destination) {
                    AppTagPill(text: countdown, style: .countdown)
                }

                if !destination.notes.isEmpty {
                    Text(destination.notes)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                }
            }
        }
        .padding(14)
        .appCellSurface(cornerRadius: 18, accentBorder: true)
        .pulseHighlight(.constant(isPulsing))
    }
}

struct ChecklistItemCell: View {
    let title: String
    let isChecked: Bool
    var showDragHandle: Bool = false
    var isPulsing: Bool = false
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(
                            isChecked
                                ? AnyShapeStyle(LinearGradient(
                                    colors: [Color("AppPrimary").opacity(0.28), Color("AppAccent").opacity(0.14)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                : AnyShapeStyle(Color("AppBackground").opacity(0.4))
                        )
                        .frame(width: 28, height: 28)
                    Image(systemName: isChecked ? "checkmark" : "")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppAccent"))
                }

                Text(title)
                    .font(.body.weight(isChecked ? .regular : .medium))
                    .foregroundStyle(isChecked ? Color("AppTextSecondary") : Color("AppTextPrimary"))
                    .strikethrough(isChecked)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if showDragHandle && !isChecked {
                    Image(systemName: "line.3.horizontal")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary").opacity(0.6))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .appCellSurface(cornerRadius: 14)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isChecked ? Color("AppAccent").opacity(0.35) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .pulseHighlight(.constant(isPulsing))
    }
}

struct ItineraryDayCell: View {
    let day: ItineraryDay
    let isExpanded: Bool
    let onToggle: () -> Void
    let onAddActivity: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack(spacing: 12) {
                    AppIconBadge(iconName: "calendar", size: 40, iconSize: 16, style: .primary)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Day \(day.dayNumber)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color("AppPrimary"))
                        Text(day.title)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text("\(day.activities.count) activities")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .foregroundStyle(Color("AppAccent"))
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(day.activities) { activity in
                        HStack(alignment: .top, spacing: 10) {
                            Circle()
                                .fill(Color("AppPrimary"))
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 8) {
                                    if !activity.timeLabel.isEmpty {
                                        AppTagPill(text: activity.timeLabel, style: .accent)
                                    }
                                    Text(activity.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color("AppTextPrimary"))
                                }
                                if !activity.notes.isEmpty {
                                    Text(activity.notes)
                                        .font(.caption)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                }
                            }
                        }
                        .padding(.leading, 8)
                    }

                    Button(action: onAddActivity) {
                        Label("Add Activity", systemImage: "plus.circle.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color("AppPrimary"))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
        }
        .appCellSurface(cornerRadius: 18)
    }
}

struct DocumentCell: View {
    let document: TravelDocument
    let showWarning: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                AppIconBadge(
                    iconName: document.checked ? "checkmark.seal.fill" : "doc.fill",
                    size: 44,
                    iconSize: 18,
                    style: document.checked ? .success : (showWarning ? .warning : .muted)
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(document.title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(document.checked ? Color("AppTextSecondary") : Color("AppTextPrimary"))
                        .strikethrough(document.checked)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    if let expiry = document.expiryDate {
                        HStack(spacing: 4) {
                            if showWarning {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption2)
                                    .foregroundStyle(Color("AppPrimary"))
                            }
                            Text("Expires \(expiry.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundStyle(showWarning ? Color("AppPrimary") : Color("AppTextSecondary"))
                        }
                    }
                }

                Spacer()

                Image(systemName: document.checked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(document.checked ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.5))
            }
            .padding(14)
            .appCellSurface(cornerRadius: 16)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(showWarning ? Color("AppPrimary").opacity(0.45) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ExpenseCell: View {
    let expense: TripExpense

    var body: some View {
        HStack(spacing: 14) {
            AppIconBadge(iconName: expense.category.iconName, size: 44, iconSize: 18, style: .accent)

            VStack(alignment: .leading, spacing: 4) {
                Text(expense.category.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                if !expense.note.isEmpty {
                    Text(expense.note)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                }
                Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
            }

            Spacer()

            Text("\(expense.currencyCode) \(String(format: "%.2f", expense.amount))")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("AppPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(14)
        .appCellSurface(cornerRadius: 16)
    }
}

struct SettingsRowCell: View {
    let title: String
    let iconName: String
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                AppIconBadge(
                    iconName: iconName,
                    size: 40,
                    iconSize: 16,
                    style: isDestructive ? .warning : .primary
                )
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(isDestructive ? .red : Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextSecondary").opacity(0.6))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct AchievementCell: View {
    let achievement: Achievement
    let isUnlocked: Bool
    let unlockedDate: Date?

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                if isUnlocked {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color("AppPrimary").opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 40
                            )
                        )
                        .frame(width: 72, height: 72)
                }
                AppIconBadge(
                    iconName: achievement.iconName,
                    size: 56,
                    iconSize: 24,
                    style: isUnlocked ? .primary : .muted
                )
            }

            Text(achievement.title)
                .font(.caption.weight(.bold))
                .foregroundStyle(isUnlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Text(achievement.description)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)

            if let unlockedDate, isUnlocked {
                AppTagPill(text: unlockedDate.formatted(date: .abbreviated, time: .omitted), style: .accent)
            } else {
                AppTagPill(text: "Locked", style: .muted)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 150)
        .appCellSurface(cornerRadius: 18, accentBorder: isUnlocked)
        .opacity(isUnlocked ? 1 : 0.82)
    }
}

struct PhraseCell: View {
    let phrase: TravelPhrase
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    AppIconBadge(iconName: "text.bubble.fill", size: 36, iconSize: 14, style: .accent)
                    Text(phrase.english)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .foregroundStyle(Color("AppAccent"))
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 8) {
                    phraseLine("Spanish", phrase.spanish)
                    phraseLine("French", phrase.french)
                    phraseLine("German", phrase.german)
                    phraseLine("Italian", phrase.italian)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
        }
        .appCellSurface(cornerRadius: 16)
    }

    private func phraseLine(_ language: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            AppTagPill(text: language, style: .accent)
            Text(text)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct CurrencyRateCell: View {
    let rate: CurrencyRate
    let baseCode: String
    let amount: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                AppIconBadge(iconName: "dollarsign.circle.fill", size: 40, iconSize: 18, style: .primary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(rate.code)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color("AppPrimary"))
                    Text(rate.name)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(rate.symbol)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
                Text(String(format: "%.2f", amount * rate.rate))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            AppTagPill(text: "1 \(baseCode) = \(String(format: "%.4f", rate.rate)) \(rate.code)", style: .muted)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCellSurface(cornerRadius: 20, accentBorder: true)
        .padding(.horizontal, 4)
    }
}

struct EmergencyInfoCell: View {
    let info: EmergencyInfo
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    AppIconBadge(iconName: "phone.fill", size: 40, iconSize: 16, style: .warning)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(info.country)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text("Emergency: \(info.emergencyNumber)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AppPrimary"))
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .foregroundStyle(Color("AppAccent"))
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    detailRow("Emergency", info.emergencyNumber)
                    detailRow("Driving", info.drivingSide)
                    Text(info.embassyNote)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .padding(.top, 4)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
        }
        .appCellSurface(cornerRadius: 18)
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            AppTagPill(text: label, style: .accent)
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color("AppTextPrimary"))
        }
    }
}

struct TemplateCell: View {
    let template: PackingTemplate

    var body: some View {
        HStack(spacing: 14) {
            AppIconBadge(iconName: template.iconName, size: 48, iconSize: 22, style: .primary)
            VStack(alignment: .leading, spacing: 4) {
                Text(template.title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("\(template.items.count) items included")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(template.items.prefix(3).joined(separator: " · "))
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary").opacity(0.8))
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "plus.circle.fill")
                .foregroundStyle(Color("AppPrimary"))
        }
        .padding(14)
        .appCellSurface(cornerRadius: 16)
    }
}

struct CurrencyPickerCell: View {
    let currency: CurrencyRate

    var body: some View {
        HStack(spacing: 14) {
            Text(currency.code)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color("AppPrimary"))
                .frame(width: 44, alignment: .leading)
            Text(currency.name)
                .font(.subheadline)
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer()
            Text(currency.symbol)
                .font(.title3)
                .foregroundStyle(Color("AppAccent"))
        }
        .padding(.vertical, 4)
    }
}

struct DuplicateTripCell: View {
    let name: String
    let itemCount: Int

    var body: some View {
        HStack(spacing: 14) {
            AppIconBadge(iconName: "doc.on.doc.fill", size: 40, iconSize: 16, style: .accent)
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                AppTagPill(text: "\(itemCount) packing items", style: .primary)
            }
            Spacer()
            Image(systemName: "arrow.right.circle.fill")
                .foregroundStyle(Color("AppPrimary"))
        }
        .padding(14)
        .appCellSurface(cornerRadius: 16, accentBorder: true)
    }
}
