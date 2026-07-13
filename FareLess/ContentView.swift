//
//  ContentView.swift
//  FareLess
//
//  Created by Dmitriy Kharitonov on 13.07.2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage(OnboardingStorageKey.hasCompletedOnboarding) private var hasCompletedOnboarding = false
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
                viewModel: HomeViewModel(
                    summaryProvider: InMemoryHomeSummaryProvider(
                        records: savedRides.map(\.homeSavingsRecord)
                    ),
                    startRideAction: startRide
                )
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
            String(localized: "home.navigation.title")
        case .active:
            "Поездка"
        case .result:
            "Результат"
        }
    }

    private var monthlySavings: Int {
        savedRides
            .filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }
            .reduce(0) { $0 + $1.savingsMinorUnits }
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

    var homeSavingsRecord: HomeSavingsRecord {
        HomeSavingsRecord(
            finishedAt: date,
            savingsMinorUnits: savingsMinorUnits,
            currencyCode: "RUB"
        )
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
