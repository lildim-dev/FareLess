//
//  RideHistoryView.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import SwiftUI

struct RideHistoryView: View {
    @State private var viewModel: RideHistoryViewModel

    init(viewModel: RideHistoryViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            content
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(LocalizedStringKey("rideHistory.navigation.title"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            loadingView
        case .loaded(let rides):
            rideList(rides)
        case .empty:
            emptyView
        case .failed:
            failedView
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .padding(.top, 80)

            RideHistoryRow(
                date: String(localized: "rideHistory.date.today"),
                savings: CurrencyFormatter.formattedMinorUnits(0, currencyCode: "RUB"),
                distance: RideHistoryFormatters.distance(0),
                duration: RideHistoryFormatters.duration(0)
            )
            .redacted(reason: .placeholder)
        }
    }

    private func rideList(_ rides: [RideHistoryItem]) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(rides) { ride in
                NavigationLink {
                    RideDetailsView(
                        viewModel: RideDetailsViewModel(ride: ride)
                    )
                } label: {
                    RideHistoryRow(
                        date: viewModel.formattedDate(for: ride),
                        savings: viewModel.formattedSavings(for: ride),
                        distance: viewModel.formattedDistance(for: ride),
                        duration: viewModel.formattedDuration(for: ride)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var emptyView: some View {
        ContentUnavailableView(
            LocalizedStringKey("rideHistory.empty.title"),
            systemImage: "clock.arrow.circlepath",
            description: Text(LocalizedStringKey("rideHistory.empty.description"))
        )
        .padding(.top, 80)
    }

    private var failedView: some View {
        VStack(spacing: 18) {
            ContentUnavailableView(
                LocalizedStringKey("rideHistory.error.title"),
                systemImage: "exclamationmark.triangle",
                description: nil
            )

            Button {
                Task {
                    await viewModel.retry()
                }
            } label: {
                Label(LocalizedStringKey("rideHistory.error.retry"), systemImage: "arrow.clockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
        }
        .padding(.top, 80)
    }
}

#Preview("Две поездки") {
    NavigationStack {
        RideHistoryView(
            viewModel: RideHistoryViewModel(
                historyProvider: InMemoryRideHistoryProvider()
            )
        )
    }
}

#Preview("Пусто") {
    NavigationStack {
        RideHistoryView(
            viewModel: RideHistoryViewModel(
                historyProvider: PreviewRideHistoryProvider(rides: [])
            )
        )
    }
}

#Preview("Ошибка") {
    NavigationStack {
        RideHistoryView(
            viewModel: RideHistoryViewModel(
                historyProvider: PreviewFailingRideHistoryProvider()
            )
        )
    }
}

private struct PreviewRideHistoryProvider: RideHistoryProviding {
    let rides: [RideHistoryItem]

    func fetchRides() async throws -> [RideHistoryItem] {
        rides
    }
}

private struct PreviewFailingRideHistoryProvider: RideHistoryProviding {
    func fetchRides() async throws -> [RideHistoryItem] {
        throw PreviewRideHistoryError.failed
    }
}

private enum PreviewRideHistoryError: Error {
    case failed
}
