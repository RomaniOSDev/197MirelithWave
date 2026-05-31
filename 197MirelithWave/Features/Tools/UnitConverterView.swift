import SwiftUI

enum UnitConversionType: String, CaseIterable, Identifiable {
    case distance
    case temperature
    case weight

    var id: String { rawValue }

    var title: String {
        switch self {
        case .distance: return "Distance"
        case .temperature: return "Temp"
        case .weight: return "Weight"
        }
    }

    var iconName: String {
        switch self {
        case .distance: return "road.lanes"
        case .temperature: return "thermometer.medium"
        case .weight: return "scalemass.fill"
        }
    }
}

struct UnitConverterView: View {
    @State private var conversionType: UnitConversionType = .distance
    @State private var inputValue = "100"
    @State private var distanceFromKm = true
    @State private var tempFromCelsius = true
    @State private var weightFromKg = true

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AppSectionHeader(title: "Unit Converter", subtitle: "Quick travel conversions")

                HStack(spacing: 8) {
                    ForEach(UnitConversionType.allCases) { type in
                        AppSegmentTab(
                            title: type.title,
                            iconName: type.iconName,
                            isSelected: conversionType == type
                        ) {
                            FeedbackManager.lightTap()
                            conversionType = type
                        }
                    }
                }

                AppCard(accentBorder: true) {
                    VStack(spacing: 16) {
                        HStack(spacing: 10) {
                            AppIconBadge(iconName: conversionType.iconName, size: 40, iconSize: 18, style: .primary)
                            TextField("Enter value", text: $inputValue)
                                .keyboardType(.decimalPad)
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(Color("AppTextPrimary"))
                        }

                        conversionContent
                    }
                    .padding(16)
                }
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private var conversionContent: some View {
        switch conversionType {
        case .distance:
            directionToggle(from: "Kilometers", to: "Miles", isFromFirst: $distanceFromKm)
            resultDisplay(from: distanceFromKm ? "km" : "mi", to: distanceFromKm ? "mi" : "km", value: convertedDistance)
        case .temperature:
            directionToggle(from: "Celsius", to: "Fahrenheit", isFromFirst: $tempFromCelsius)
            resultDisplay(from: tempFromCelsius ? "°C" : "°F", to: tempFromCelsius ? "°F" : "°C", value: convertedTemperature)
        case .weight:
            directionToggle(from: "Kilograms", to: "Pounds", isFromFirst: $weightFromKg)
            resultDisplay(from: weightFromKg ? "kg" : "lb", to: weightFromKg ? "lb" : "kg", value: convertedWeight)
        }
    }

    private func directionToggle(from: String, to: String, isFromFirst: Binding<Bool>) -> some View {
        HStack(spacing: 10) {
            unitButton(from, isActive: isFromFirst.wrappedValue) { isFromFirst.wrappedValue = true }
            Image(systemName: "arrow.left.arrow.right")
                .foregroundStyle(Color("AppAccent"))
                .font(.caption.weight(.bold))
            unitButton(to, isActive: !isFromFirst.wrappedValue) { isFromFirst.wrappedValue = false }
        }
    }

    private func unitButton(_ title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(isActive ? Color("AppBackground") : Color("AppTextSecondary"))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(isActive ? Color("AppPrimary") : Color("AppBackground").opacity(0.4))
                )
        }
        .buttonStyle(.plain)
    }

    private func resultDisplay(from: String, to: String, value: Double) -> some View {
        VStack(spacing: 10) {
            Text("\(inputValue) \(from)")
                .font(.title3)
                .foregroundStyle(Color("AppTextSecondary"))
            Image(systemName: "equal.circle.fill")
                .font(.title2)
                .foregroundStyle(Color("AppAccent"))
            Text(String(format: "%.2f %@", value, to))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(Color("AppPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var inputNumber: Double { Double(inputValue) ?? 0 }
    private var convertedDistance: Double { distanceFromKm ? inputNumber * 0.621371 : inputNumber / 0.621371 }
    private var convertedTemperature: Double { tempFromCelsius ? (inputNumber * 9 / 5) + 32 : (inputNumber - 32) * 5 / 9 }
    private var convertedWeight: Double { weightFromKg ? inputNumber * 2.20462 : inputNumber / 2.20462 }
}
