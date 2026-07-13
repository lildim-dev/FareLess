//
//  RideResultViewModel.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class RideResultViewModel {
    let snapshot: RideResultSnapshot
    private let onDone: () -> Void

    init(
        snapshot: RideResultSnapshot,
        onDone: @escaping () -> Void
    ) {
        self.snapshot = snapshot
        self.onDone = onDone
    }

    var formattedSavings: String {
        CurrencyFormatter.formattedMinorUnits(snapshot.savingsMinorUnits, currencyCode: "RUB")
    }

    var formattedDistance: String {
        let formatter = MeasurementFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .short
        formatter.numberFormatter.minimumFractionDigits = 1
        formatter.numberFormatter.maximumFractionDigits = 1

        let kilometers = Measurement(value: snapshot.distanceMeters / 1_000, unit: UnitLength.kilometers)
        return formatter.string(from: kilometers)
    }

    var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.calendar = .autoupdatingCurrent
        formatter.unitsStyle = .short
        formatter.allowedUnits = [.minute]
        formatter.zeroFormattingBehavior = .dropAll

        return formatter.string(from: snapshot.durationSeconds) ?? ""
    }

    func done() {
        onDone()
    }
}
