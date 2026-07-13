//
//  ContentView.swift
//  FareLess
//
//  Created by Dmitriy Kharitonov on 13.07.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var hasCompletedOnboarding = false
    @State private var rideState: RideState = .idle
    @State private var elapsedSeconds = 0
    @State private var distanceMeters = 0
    @State private var savedRides: [RidePreview] = []
    @State private var latestResult: RideResult?

    private let sampleTaxiPriceMinorUnits = 62_000

    var body: some View {
        if hasCompletedOnboarding {
            NavigationStack {
                currentScreen
                    .navigationTitle(navigationTitle)
                    .navigationBarTitleDisplayMode(.inline)
            }
        } else {
            OnboardingView {
                hasCompletedOnboarding = true
            }
        }
    }

    @ViewBuilder
    private var currentScreen: some View {
        switch rideState {
        case .idle:
            HomeView(
                todaySavings: savingsToday,
                monthlySavings: monthlySavings,
                lifetimeSavings: lifetimeSavings,
                completedRideCount: savedRides.count,
                recentRides: Array(savedRides.prefix(3)),
                startRide: startRide
            )
        case .active:
            ActiveRideView(
                elapsedSeconds: elapsedSeconds,
                distanceMeters: distanceMeters,
                finishRide: finishRide
            )
        case .result:
            if let latestResult {
                RideResultView(
                    result: latestResult,
                    monthlySavings: monthlySavings,
                    close: {
                        rideState = .idle
                    }
                )
            }
        }
    }

    private var navigationTitle: String {
        switch rideState {
        case .idle:
            "FareLess"
        case .active:
            "Поездка"
        case .result:
            "Результат"
        }
    }

    private var savingsToday: Int {
        savedRides
            .filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.savingsMinorUnits }
    }

    private var monthlySavings: Int {
        savedRides
            .filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }
            .reduce(0) { $0 + $1.savingsMinorUnits }
    }

    private var lifetimeSavings: Int {
        savedRides.reduce(0) { $0 + $1.savingsMinorUnits }
    }

    private func startRide() {
        elapsedSeconds = 0
        distanceMeters = 0
        latestResult = nil
        rideState = .active
    }

    private func finishRide() {
        elapsedSeconds = 16 * 60
        distanceMeters = 2_800

        let draft = RideDraft(
            taxiPriceMinorUnits: sampleTaxiPriceMinorUnits,
            scooterCostMinorUnits: 0,
            currencyCode: "RUB"
        )
        let savingsMinorUnits = SavingsCalculator.savingsMinorUnits(for: draft)
        let result = RideResult(
            taxiPriceMinorUnits: sampleTaxiPriceMinorUnits,
            savingsMinorUnits: savingsMinorUnits,
            distanceMeters: distanceMeters,
            durationSeconds: elapsedSeconds,
            date: Date()
        )

        latestResult = result
        savedRides.insert(
            RidePreview(
                date: result.date,
                distanceMeters: result.distanceMeters,
                durationSeconds: result.durationSeconds,
                taxiPriceMinorUnits: result.taxiPriceMinorUnits,
                savingsMinorUnits: result.savingsMinorUnits
            ),
            at: 0
        )
        rideState = .result
    }
}

private enum RideState {
    case idle
    case active
    case result
}

private struct RideResult {
    let taxiPriceMinorUnits: Int
    let savingsMinorUnits: Int
    let distanceMeters: Int
    let durationSeconds: Int
    let date: Date
}

private struct RidePreview: Identifiable {
    let id = UUID()
    let date: Date
    let distanceMeters: Int
    let durationSeconds: Int
    let taxiPriceMinorUnits: Int
    let savingsMinorUnits: Int
}

private struct OnboardingView: View {
    @State private var selection = 0

    let complete: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            TabView(selection: $selection) {
                OnboardingCard(
                    systemImage: "scooter",
                    title: "Сколько денег экономит ваш самокат?",
                    subtitle: "Автоматически считаем стоимость аналогичной поездки на такси."
                )
                .tag(0)

                OnboardingCard(
                    systemImage: "sparkles",
                    title: "Никаких ручных расчётов",
                    subtitle: "Просто ездите. FareLess сам покажет экономию после поездки."
                )
                .tag(1)

                OnboardingCard(
                    systemImage: "location.fill",
                    title: "Разрешения",
                    subtitle: "Геолокация нужна только во время поездки. Уведомления можно включить позже."
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button {
                if selection < 2 {
                    withAnimation {
                        selection += 1
                    }
                } else {
                    complete()
                }
            } label: {
                Text(selection < 2 ? "Дальше" : "Начать")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)
        }
        .padding(.vertical, 24)
        .background(Color(.systemGroupedBackground))
    }
}

private struct OnboardingCard: View {
    let systemImage: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 22) {
            Image(systemName: systemImage)
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(.green)
                .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text(title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(28)
    }
}

private struct HomeView: View {
    let todaySavings: Int
    let monthlySavings: Int
    let lifetimeSavings: Int
    let completedRideCount: Int
    let recentRides: [RidePreview]
    let startRide: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SavingsHeader(
                    title: "Вы сэкономили сегодня",
                    amountMinorUnits: todaySavings
                )

                Button(action: startRide) {
                    Label("Начать поездку", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                HStack(spacing: 12) {
                    MetricTile(title: "За месяц", value: MoneyFormatter.rubles(fromMinorUnits: monthlySavings))
                    MetricTile(title: "Всего", value: MoneyFormatter.rubles(fromMinorUnits: lifetimeSavings))
                    MetricTile(title: "Поездки", value: completedRideCount.formatted())
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Недавние поездки")
                        .font(.headline)

                    if recentRides.isEmpty {
                        ContentUnavailableView(
                            "Пока нет поездок",
                            systemImage: "scooter",
                            description: Text("Начните первую поездку, чтобы увидеть экономию.")
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                    } else {
                        ForEach(recentRides) { ride in
                            RidePreviewRow(ride: ride)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

private struct ActiveRideView: View {
    let elapsedSeconds: Int
    let distanceMeters: Int
    let finishRide: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Label("Геолокация активна", systemImage: "location.fill")
                    .font(.headline)
                    .foregroundStyle(.green)

                Text("Поездка записывается")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 12) {
                MetricTile(title: "Время", value: durationText(elapsedSeconds))
                MetricTile(title: "Дистанция", value: distanceText(distanceMeters))
            }

            Spacer()

            Button(role: .destructive, action: finishRide) {
                Label("Завершить", systemImage: "stop.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

private struct RideResultView: View {
    let result: RideResult
    let monthlySavings: Int
    let close: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SavingsHeader(
                    title: "Вы сэкономили",
                    amountMinorUnits: result.savingsMinorUnits
                )

                VStack(spacing: 12) {
                    ResultRow(title: "Такси", value: "~\(MoneyFormatter.rubles(fromMinorUnits: result.taxiPriceMinorUnits))")
                    ResultRow(title: "За месяц", value: MoneyFormatter.rubles(fromMinorUnits: monthlySavings))
                    ResultRow(title: "Дистанция", value: distanceText(result.distanceMeters))
                    ResultRow(title: "Время", value: durationText(result.durationSeconds))
                    ResultRow(title: "Дата", value: result.date.formatted(date: .abbreviated, time: .shortened))
                }

                Label("Поездка сохранена", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.green)

                Button(action: close) {
                    Text("Готово")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

private struct SavingsHeader: View {
    let title: String
    let amountMinorUnits: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(MoneyFormatter.rubles(fromMinorUnits: amountMinorUnits))
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .contentTransition(.numericText())
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct MetricTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct RidePreviewRow: View {
    let ride: RidePreview

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(ride.date, format: .dateTime.day().month().hour().minute())
                    .font(.headline)

                Text("\(distanceText(ride.distanceMeters)) • \(durationText(ride.durationSeconds))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(MoneyFormatter.rubles(fromMinorUnits: ride.savingsMinorUnits))
                .font(.headline)
                .foregroundStyle(.green)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct ResultRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}

private func durationText(_ seconds: Int) -> String {
    let minutes = max(seconds / 60, 0)
    return "\(minutes) мин"
}

private func distanceText(_ meters: Int) -> String {
    if meters >= 1_000 {
        let kilometers = Double(meters) / 1_000
        return kilometers.formatted(.number.precision(.fractionLength(1))) + " км"
    }

    return "\(meters) м"
}

#Preview {
    ContentView()
}
