//
//  HomeViewModelTests.swift
//  FareLessTests
//
//  Created by Codex on 13.07.2026.
//

import Foundation
import Testing
@testable import FareLess

@MainActor
struct HomeViewModelTests {
    @Test func calculatesTodaySavings() throws {
        let calculator = makeCalculator(now: try makeDate(year: 2026, month: 1, day: 15, hour: 12))
        let records = [
            HomeSavingsRecord(finishedAt: try makeDate(year: 2026, month: 1, day: 15, hour: 9), savingsMinorUnits: 56_000, currencyCode: "RUB"),
            HomeSavingsRecord(finishedAt: try makeDate(year: 2026, month: 1, day: 15, hour: 10), savingsMinorUnits: 20_000, currencyCode: "RUB")
        ]

        let summary = calculator.summary(from: records)

        #expect(summary.todaySavingsMinorUnits == 76_000)
    }

    @Test func calculatesCurrentMonthSavings() throws {
        let calculator = makeCalculator(now: try makeDate(year: 2026, month: 1, day: 15, hour: 12))
        let records = [
            HomeSavingsRecord(finishedAt: try makeDate(year: 2026, month: 1, day: 1, hour: 9), savingsMinorUnits: 50_000, currencyCode: "RUB"),
            HomeSavingsRecord(finishedAt: try makeDate(year: 2026, month: 1, day: 31, hour: 10), savingsMinorUnits: 60_000, currencyCode: "RUB")
        ]

        let summary = calculator.summary(from: records)

        #expect(summary.monthlySavingsMinorUnits == 110_000)
    }

    @Test func calculatesLifetimeSavings() throws {
        let calculator = makeCalculator(now: try makeDate(year: 2026, month: 1, day: 15, hour: 12))
        let records = [
            HomeSavingsRecord(finishedAt: try makeDate(year: 2025, month: 12, day: 10, hour: 9), savingsMinorUnits: 10_000, currencyCode: "RUB"),
            HomeSavingsRecord(finishedAt: try makeDate(year: 2026, month: 1, day: 15, hour: 10), savingsMinorUnits: 20_000, currencyCode: "RUB")
        ]

        let summary = calculator.summary(from: records)

        #expect(summary.lifetimeSavingsMinorUnits == 30_000)
    }

    @Test func previousDayDoesNotCountAsToday() throws {
        let calculator = makeCalculator(now: try makeDate(year: 2026, month: 1, day: 15, hour: 12))
        let records = [
            HomeSavingsRecord(finishedAt: try makeDate(year: 2026, month: 1, day: 14, hour: 23), savingsMinorUnits: 70_000, currencyCode: "RUB")
        ]

        let summary = calculator.summary(from: records)

        #expect(summary.todaySavingsMinorUnits == 0)
    }

    @Test func previousMonthDoesNotCountAsCurrentMonth() throws {
        let calculator = makeCalculator(now: try makeDate(year: 2026, month: 1, day: 15, hour: 12))
        let records = [
            HomeSavingsRecord(finishedAt: try makeDate(year: 2025, month: 12, day: 31, hour: 23), savingsMinorUnits: 70_000, currencyCode: "RUB")
        ]

        let summary = calculator.summary(from: records)

        #expect(summary.monthlySavingsMinorUnits == 0)
    }

    @Test func allCompletedTripsCountAsLifetimeSavings() throws {
        let calculator = makeCalculator(now: try makeDate(year: 2026, month: 1, day: 15, hour: 12))
        let records = [
            HomeSavingsRecord(finishedAt: try makeDate(year: 2025, month: 11, day: 1, hour: 8), savingsMinorUnits: 10_000, currencyCode: "RUB"),
            HomeSavingsRecord(finishedAt: try makeDate(year: 2025, month: 12, day: 1, hour: 8), savingsMinorUnits: 20_000, currencyCode: "RUB"),
            HomeSavingsRecord(finishedAt: try makeDate(year: 2026, month: 1, day: 15, hour: 8), savingsMinorUnits: 30_000, currencyCode: "RUB")
        ]

        let summary = calculator.summary(from: records)

        #expect(summary.lifetimeSavingsMinorUnits == 60_000)
    }

    @Test func emptyRecordsReturnZeroSavings() throws {
        let calculator = makeCalculator(now: try makeDate(year: 2026, month: 1, day: 15, hour: 12))

        let summary = calculator.summary(from: [])

        #expect(summary.todaySavingsMinorUnits == 0)
        #expect(summary.monthlySavingsMinorUnits == 0)
        #expect(summary.lifetimeSavingsMinorUnits == 0)
    }

    @Test func moneyValuesUseIntegerMinorUnits() {
        let summary = HomeSummary(
            todaySavingsMinorUnits: 56_000,
            monthlySavingsMinorUnits: 1_243_000,
            lifetimeSavingsMinorUnits: 1_894_000,
            currencyCode: "RUB"
        )

        #expect(type(of: summary.todaySavingsMinorUnits) == Int.self)
        #expect(type(of: summary.monthlySavingsMinorUnits) == Int.self)
        #expect(type(of: summary.lifetimeSavingsMinorUnits) == Int.self)
    }

    @Test func repeatedLoadUpdatesState() async {
        let provider = MutableHomeSummaryProvider(
            summaries: [
                .empty,
                HomeSummary(
                    todaySavingsMinorUnits: 56_000,
                    monthlySavingsMinorUnits: 56_000,
                    lifetimeSavingsMinorUnits: 56_000,
                    currencyCode: "RUB"
                )
            ]
        )
        let viewModel = HomeViewModel(summaryProvider: provider, startRideAction: {})

        await viewModel.load()
        await viewModel.load()

        #expect(viewModel.state == .loaded(HomeSummary(
            todaySavingsMinorUnits: 56_000,
            monthlySavingsMinorUnits: 56_000,
            lifetimeSavingsMinorUnits: 56_000,
            currencyCode: "RUB"
        )))
    }

    @Test func loadingErrorMovesStateToError() async {
        let viewModel = HomeViewModel(
            summaryProvider: FailingHomeSummaryProvider(),
            startRideAction: {}
        )

        await viewModel.load()

        #expect(viewModel.state == .error)
    }

    @Test func retryRunsLoadAgain() async {
        let provider = MutableHomeSummaryProvider(
            summaries: [
                HomeSummary(
                    todaySavingsMinorUnits: 10_000,
                    monthlySavingsMinorUnits: 10_000,
                    lifetimeSavingsMinorUnits: 10_000,
                    currencyCode: "RUB"
                )
            ]
        )
        let viewModel = HomeViewModel(summaryProvider: provider, startRideAction: {})

        await viewModel.retry()

        #expect(provider.loadCount == 1)
        #expect(viewModel.state == .loaded(HomeSummary(
            todaySavingsMinorUnits: 10_000,
            monthlySavingsMinorUnits: 10_000,
            lifetimeSavingsMinorUnits: 10_000,
            currencyCode: "RUB"
        )))
    }

    @Test func startRideActionRunsOnce() {
        let actionCounter = ActionCounter()
        let viewModel = HomeViewModel(
            summaryProvider: StaticHomeSummaryProvider(summary: .empty),
            startRideAction: {
                actionCounter.count += 1
            }
        )

        viewModel.startRide()

        #expect(actionCounter.count == 1)
    }

    private func makeCalculator(now: Date) -> HomeSummaryCalculator {
        HomeSummaryCalculator(
            calendar: fixedCalendar,
            dateProvider: FixedDateProvider(now: now)
        )
    }

    private var fixedCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }

    private func makeDate(year: Int, month: Int, day: Int, hour: Int) throws -> Date {
        let date = fixedCalendar.date(from: DateComponents(
            timeZone: fixedCalendar.timeZone,
            year: year,
            month: month,
            day: day,
            hour: hour
        ))

        return try #require(date)
    }
}

private struct FixedDateProvider: DateProviding {
    let now: Date
}

private final class StaticHomeSummaryProvider: HomeSummaryProviding {
    private let summary: HomeSummary

    init(summary: HomeSummary) {
        self.summary = summary
    }

    func loadSummary() async throws -> HomeSummary {
        summary
    }
}

private final class MutableHomeSummaryProvider: HomeSummaryProviding {
    private var summaries: [HomeSummary]
    private(set) var loadCount = 0

    init(summaries: [HomeSummary]) {
        self.summaries = summaries
    }

    func loadSummary() async throws -> HomeSummary {
        loadCount += 1

        guard !summaries.isEmpty else {
            return .empty
        }

        return summaries.removeFirst()
    }
}

private struct FailingHomeSummaryProvider: HomeSummaryProviding {
    func loadSummary() async throws -> HomeSummary {
        throw TestError.loadFailed
    }
}

private enum TestError: Error {
    case loadFailed
}

private final class ActionCounter {
    var count = 0
}
