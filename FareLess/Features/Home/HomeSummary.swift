//
//  HomeSummary.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import Foundation

struct HomeSummary: Equatable {
    let todaySavingsMinorUnits: Int
    let monthlySavingsMinorUnits: Int
    let lifetimeSavingsMinorUnits: Int
    let currencyCode: String

    static let empty = HomeSummary(
        todaySavingsMinorUnits: 0,
        monthlySavingsMinorUnits: 0,
        lifetimeSavingsMinorUnits: 0,
        currencyCode: "RUB"
    )

    var isEmpty: Bool {
        todaySavingsMinorUnits == 0
            && monthlySavingsMinorUnits == 0
            && lifetimeSavingsMinorUnits == 0
    }
}

struct HomeSavingsRecord: Equatable {
    let finishedAt: Date
    let savingsMinorUnits: Int
    let currencyCode: String
}

protocol HomeSummaryProviding {
    func loadSummary() async throws -> HomeSummary
}
