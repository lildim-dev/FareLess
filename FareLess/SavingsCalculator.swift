//
//  SavingsCalculator.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import Foundation

struct RideDraft: Equatable {
    let taxiPriceMinorUnits: Int
    let scooterCostMinorUnits: Int
    let currencyCode: String
}

enum SavingsCalculator {
    static func savingsMinorUnits(for ride: RideDraft) -> Int {
        max(ride.taxiPriceMinorUnits - ride.scooterCostMinorUnits, 0)
    }
}

enum MoneyFormatter {
    static func rubles(fromMinorUnits minorUnits: Int) -> String {
        CurrencyFormatter.formattedMinorUnits(minorUnits, currencyCode: "RUB")
    }
}
