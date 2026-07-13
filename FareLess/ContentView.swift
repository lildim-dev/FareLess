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
    @State private var savedRides: [RidePreview] = []

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
            ActiveRideView(onFinish: finishRide)
        case .result:
            RideResultView(
                viewModel: RideResultViewModel(
                    snapshot: .demo,
                    onDone: {
                        rideState = .idle
                    }
                )
            )
        }
    }

    private var navigationTitle: String {
        switch rideState {
        case .idle:
            String(localized: "home.navigation.title")
        case .active:
            String(localized: "activeRide.navigation.title")
        case .result:
            String(localized: "rideResult.navigation.title")
        }
    }

    private func startRide() {
        rideState = .active
    }

    private func finishRide() {
        rideState = .result
    }
}

private enum RideState {
    case idle
    case active
    case result
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

#Preview {
    ContentView()
}
