//
//  HomeView.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: HomeViewModel
    private let rideHistoryProvider: RideHistoryProviding

    init(
        viewModel: HomeViewModel,
        rideHistoryProvider: RideHistoryProviding = InMemoryRideHistoryProvider()
    ) {
        self._viewModel = State(initialValue: viewModel)
        self.rideHistoryProvider = rideHistoryProvider
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                content
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
            }

            startRideButton
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .background(.bar)
        }
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    RideHistoryView(
                        viewModel: RideHistoryViewModel(
                            historyProvider: rideHistoryProvider
                        )
                    )
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                }
                .accessibilityLabel(Text(LocalizedStringKey("rideHistory.open.accessibilityLabel")))
            }
        }
        .task {
            await viewModel.load()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else {
                return
            }

            Task {
                await viewModel.load()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            loadingView
        case .loaded(let summary):
            summaryView(summary: summary, showsEmptyMessage: false)
        case .empty(let summary):
            summaryView(summary: summary, showsEmptyMessage: true)
        case .error:
            errorView
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .padding(.top, 80)

            SavingsHeroCard(
                amount: CurrencyFormatter.formattedMinorUnits(0, currencyCode: "RUB"),
                accessibilityAmount: CurrencyFormatter.accessibilityFormattedMinorUnits(0, currencyCode: "RUB")
            )
            .redacted(reason: .placeholder)

            metricsView(summary: .empty)
                .redacted(reason: .placeholder)
        }
    }

    private var errorView: some View {
        VStack(spacing: 18) {
            ContentUnavailableView(
                LocalizedStringKey("home.error.title"),
                systemImage: "exclamationmark.triangle",
                description: nil
            )
            .padding(.top, 48)

            Button {
                Task {
                    await viewModel.retry()
                }
            } label: {
                Label(LocalizedStringKey("home.error.retry"), systemImage: "arrow.clockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
        }
    }

    private func summaryView(summary: HomeSummary, showsEmptyMessage: Bool) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SavingsHeroCard(
                amount: CurrencyFormatter.formattedMinorUnits(
                    summary.todaySavingsMinorUnits,
                    currencyCode: summary.currencyCode
                ),
                accessibilityAmount: CurrencyFormatter.accessibilityFormattedMinorUnits(
                    summary.todaySavingsMinorUnits,
                    currencyCode: summary.currencyCode
                )
            )

            metricsView(summary: summary)

            if showsEmptyMessage {
                Text(LocalizedStringKey("home.empty.message"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
            }
        }
    }

    private func metricsView(summary: HomeSummary) -> some View {
        VStack(spacing: 12) {
            SavingsMetricView(
                titleKey: "home.savings.month.title",
                amount: CurrencyFormatter.formattedMinorUnits(
                    summary.monthlySavingsMinorUnits,
                    currencyCode: summary.currencyCode
                ),
                accessibilityLabelKey: "home.savings.month.accessibilityLabel",
                accessibilityAmount: CurrencyFormatter.accessibilityFormattedMinorUnits(
                    summary.monthlySavingsMinorUnits,
                    currencyCode: summary.currencyCode
                )
            )

            SavingsMetricView(
                titleKey: "home.savings.lifetime.title",
                amount: CurrencyFormatter.formattedMinorUnits(
                    summary.lifetimeSavingsMinorUnits,
                    currencyCode: summary.currencyCode
                ),
                accessibilityLabelKey: "home.savings.lifetime.accessibilityLabel",
                accessibilityAmount: CurrencyFormatter.accessibilityFormattedMinorUnits(
                    summary.lifetimeSavingsMinorUnits,
                    currencyCode: summary.currencyCode
                )
            )
        }
    }

    private var startRideButton: some View {
        Button {
            viewModel.startRide()
        } label: {
            Label(LocalizedStringKey("home.startRide"), systemImage: "play.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 56)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .accessibilityLabel(Text(LocalizedStringKey("home.startRide")))
    }
}

#Preview("Значения") {
    NavigationStack {
        HomeView(
            viewModel: HomePreviewFactory.viewModel(
                summary: HomeSummary(
                    todaySavingsMinorUnits: 56_000,
                    monthlySavingsMinorUnits: 1_243_000,
                    lifetimeSavingsMinorUnits: 1_894_000,
                    currencyCode: "RUB"
                )
            )
        )
        .navigationTitle(LocalizedStringKey("home.navigation.title"))
    }
}

#Preview("Пусто") {
    NavigationStack {
        HomeView(viewModel: HomePreviewFactory.viewModel(summary: .empty))
            .navigationTitle(LocalizedStringKey("home.navigation.title"))
    }
}

#Preview("Крупная сумма") {
    NavigationStack {
        HomeView(
            viewModel: HomePreviewFactory.viewModel(
                summary: HomeSummary(
                    todaySavingsMinorUnits: 123_456_700,
                    monthlySavingsMinorUnits: 1_243_000,
                    lifetimeSavingsMinorUnits: 987_654_300,
                    currencyCode: "RUB"
                )
            )
        )
        .navigationTitle(LocalizedStringKey("home.navigation.title"))
    }
}

#Preview("Тёмная тема") {
    NavigationStack {
        HomeView(
            viewModel: HomePreviewFactory.viewModel(
                summary: HomeSummary(
                    todaySavingsMinorUnits: 56_000,
                    monthlySavingsMinorUnits: 1_243_000,
                    lifetimeSavingsMinorUnits: 1_894_000,
                    currencyCode: "RUB"
                )
            )
        )
        .navigationTitle(LocalizedStringKey("home.navigation.title"))
    }
    .preferredColorScheme(.dark)
}

#Preview("Большой текст") {
    NavigationStack {
        HomeView(
            viewModel: HomePreviewFactory.viewModel(
                summary: HomeSummary(
                    todaySavingsMinorUnits: 56_000,
                    monthlySavingsMinorUnits: 1_243_000,
                    lifetimeSavingsMinorUnits: 1_894_000,
                    currencyCode: "RUB"
                )
            )
        )
        .navigationTitle(LocalizedStringKey("home.navigation.title"))
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("Маленький iPhone") {
    NavigationStack {
        HomeView(
            viewModel: HomePreviewFactory.viewModel(
                summary: HomeSummary(
                    todaySavingsMinorUnits: 56_000,
                    monthlySavingsMinorUnits: 1_243_000,
                    lifetimeSavingsMinorUnits: 1_894_000,
                    currencyCode: "RUB"
                )
            )
        )
        .navigationTitle(LocalizedStringKey("home.navigation.title"))
    }
    .frame(width: 320, height: 568)
}

private enum HomePreviewFactory {
    static func viewModel(summary: HomeSummary) -> HomeViewModel {
        HomeViewModel(
            summaryProvider: PreviewHomeSummaryProvider(summary: summary),
            startRideAction: {}
        )
    }
}

private struct PreviewHomeSummaryProvider: HomeSummaryProviding {
    let summary: HomeSummary

    func loadSummary() async throws -> HomeSummary {
        summary
    }
}
