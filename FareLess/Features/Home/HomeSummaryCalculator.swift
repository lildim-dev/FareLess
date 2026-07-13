//
//  HomeSummaryCalculator.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import Foundation

struct HomeSummaryCalculator {
    private let calendar: Calendar
    private let dateProvider: DateProviding
    private let fallbackCurrencyCode: String

    init(
        calendar: Calendar = .autoupdatingCurrent,
        dateProvider: DateProviding = SystemDateProvider(),
        fallbackCurrencyCode: String = "RUB"
    ) {
        self.calendar = calendar
        self.dateProvider = dateProvider
        self.fallbackCurrencyCode = fallbackCurrencyCode
    }

    func summary(from records: [HomeSavingsRecord]) -> HomeSummary {
        let now = dateProvider.now
        let currencyCode = records.first?.currencyCode ?? fallbackCurrencyCode

        let todaySavings = records
            .filter { calendar.isDate($0.finishedAt, inSameDayAs: now) }
            .reduce(0) { $0 + $1.savingsMinorUnits }

        let monthlySavings = records
            .filter { calendar.isDate($0.finishedAt, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.savingsMinorUnits }

        let lifetimeSavings = records.reduce(0) { $0 + $1.savingsMinorUnits }

        return HomeSummary(
            todaySavingsMinorUnits: todaySavings,
            monthlySavingsMinorUnits: monthlySavings,
            lifetimeSavingsMinorUnits: lifetimeSavings,
            currencyCode: currencyCode
        )
    }
}
