//
//  InMemoryHomeSummaryProvider.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import Foundation

struct InMemoryHomeSummaryProvider: HomeSummaryProviding {
    private let records: [HomeSavingsRecord]
    private let calculator: HomeSummaryCalculator

    init(
        records: [HomeSavingsRecord],
        calculator: HomeSummaryCalculator = HomeSummaryCalculator()
    ) {
        self.records = records
        self.calculator = calculator
    }

    func loadSummary() async throws -> HomeSummary {
        calculator.summary(from: records)
    }
}
