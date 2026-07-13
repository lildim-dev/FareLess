//
//  HomeViewModel.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import Foundation
import Observation

enum HomeViewState: Equatable {
    case loading
    case loaded(HomeSummary)
    case empty(HomeSummary)
    case error
}

@MainActor
@Observable
final class HomeViewModel {
    private let summaryProvider: HomeSummaryProviding
    private let startRideAction: () -> Void

    private(set) var state: HomeViewState = .loading

    init(
        summaryProvider: HomeSummaryProviding,
        startRideAction: @escaping () -> Void
    ) {
        self.summaryProvider = summaryProvider
        self.startRideAction = startRideAction
    }

    func load() async {
        state = .loading

        do {
            let summary = try await summaryProvider.loadSummary()
            state = summary.isEmpty ? .empty(summary) : .loaded(summary)
        } catch {
            state = .error
        }
    }

    func retry() async {
        await load()
    }

    func startRide() {
        startRideAction()
    }
}
