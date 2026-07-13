//
//  RideHistoryViewModel.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import Foundation
import Observation

enum RideHistoryViewState: Equatable {
    case loading
    case loaded([RideHistoryItem])
    case empty
    case failed
}

@MainActor
@Observable
final class RideHistoryViewModel {
    private let historyProvider: RideHistoryProviding
    private let calendar: Calendar

    private(set) var state: RideHistoryViewState = .loading

    init(
        historyProvider: RideHistoryProviding,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        self.historyProvider = historyProvider
        self.calendar = calendar
    }

    func load() async {
        state = .loading

        do {
            let rides = try await historyProvider.fetchRides()
                .sorted { $0.startedAt > $1.startedAt }
            state = rides.isEmpty ? .empty : .loaded(rides)
        } catch {
            state = .failed
        }
    }

    func retry() async {
        await load()
    }

    func formattedDate(for item: RideHistoryItem) -> String {
        if calendar.isDateInToday(item.startedAt) {
            return String(localized: "rideHistory.date.today")
        }

        if calendar.isDateInYesterday(item.startedAt) {
            return String(localized: "rideHistory.date.yesterday")
        }

        return item.startedAt.formatted(date: .abbreviated, time: .omitted)
    }

    func formattedSavings(for item: RideHistoryItem) -> String {
        CurrencyFormatter.formattedMinorUnits(item.savingsMinorUnits, currencyCode: "RUB")
    }

    func formattedDistance(for item: RideHistoryItem) -> String {
        RideHistoryFormatters.distance(item.distanceMeters)
    }

    func formattedDuration(for item: RideHistoryItem) -> String {
        RideHistoryFormatters.duration(item.durationSeconds)
    }
}

enum RideHistoryFormatters {
    static func distance(_ meters: Double) -> String {
        let formatter = MeasurementFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .short
        formatter.numberFormatter.minimumFractionDigits = meters >= 1_000 ? 1 : 0
        formatter.numberFormatter.maximumFractionDigits = meters >= 1_000 ? 1 : 0

        if meters >= 1_000 {
            return formatter.string(from: Measurement(value: meters / 1_000, unit: UnitLength.kilometers))
        }

        return formatter.string(from: Measurement(value: meters, unit: UnitLength.meters))
    }

    static func duration(_ seconds: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.calendar = .autoupdatingCurrent
        formatter.unitsStyle = .short
        formatter.allowedUnits = [.minute]
        formatter.zeroFormattingBehavior = .dropAll

        return formatter.string(from: seconds) ?? ""
    }
}
