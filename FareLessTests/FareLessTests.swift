//
//  FareLessTests.swift
//  FareLessTests
//
//  Created by Dmitriy Kharitonov on 13.07.2026.
//

import Testing
@testable import FareLess

struct FareLessTests {
    @Test func savingsEqualsTaxiPriceForPersonalScooter() {
        let ride = RideDraft(
            taxiPriceMinorUnits: 62_000,
            scooterCostMinorUnits: 0,
            currencyCode: "RUB"
        )

        #expect(SavingsCalculator.savingsMinorUnits(for: ride) == 62_000)
    }

    @Test func savingsNeverReturnsNegativeAmount() {
        let ride = RideDraft(
            taxiPriceMinorUnits: 10_000,
            scooterCostMinorUnits: 12_000,
            currencyCode: "RUB"
        )

        #expect(SavingsCalculator.savingsMinorUnits(for: ride) == 0)
    }
}
