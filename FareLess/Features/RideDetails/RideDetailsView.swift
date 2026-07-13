//
//  RideDetailsView.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import SwiftUI

struct RideDetailsView: View {
    @State private var viewModel: RideDetailsViewModel

    init(viewModel: RideDetailsViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                RideRouteMapView(
                    coordinates: viewModel.routeCoordinates,
                    startCoordinate: viewModel.startCoordinate,
                    endCoordinate: viewModel.endCoordinate,
                    region: viewModel.mapRegion
                )

                DetailSavingsCard(amount: viewModel.formattedSavings)

                VStack(spacing: 12) {
                    DetailMetricRow(
                        titleKey: "rideDetails.distance.title",
                        value: viewModel.formattedDistance
                    )
                    DetailMetricRow(
                        titleKey: "rideDetails.duration.title",
                        value: viewModel.formattedDuration
                    )
                    DetailMetricRow(
                        titleKey: "rideDetails.date.title",
                        value: viewModel.formattedDate
                    )
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(LocalizedStringKey("rideDetails.navigation.title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct DetailSavingsCard: View {
    let amount: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey("rideDetails.savings.title"))
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(amount)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
    }
}

private struct DetailMetricRow: View {
    let titleKey: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(LocalizedStringKey(titleKey))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 8)

            Text(value)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
    }
}

#Preview("С маршрутом") {
    NavigationStack {
        RideDetailsView(
            viewModel: RideDetailsViewModel(
                ride: RideDetailsPreviewFactory.rideWithRoute
            )
        )
    }
}

#Preview("Без маршрута") {
    NavigationStack {
        RideDetailsView(
            viewModel: RideDetailsViewModel(
                ride: RideDetailsPreviewFactory.rideWithoutRoute
            )
        )
    }
}

private enum RideDetailsPreviewFactory {
    static let rideWithRoute = RideHistoryItem(
        id: UUID(),
        startedAt: Date(),
        savingsMinorUnits: 62_000,
        distanceMeters: 4_700,
        durationSeconds: 18 * 60,
        route: [
            RideRoutePoint(latitude: 55.751244, longitude: 37.618423),
            RideRoutePoint(latitude: 55.753330, longitude: 37.624000),
            RideRoutePoint(latitude: 55.756000, longitude: 37.630500),
            RideRoutePoint(latitude: 55.758200, longitude: 37.637000),
            RideRoutePoint(latitude: 55.760800, longitude: 37.642600)
        ]
    )

    static let rideWithoutRoute = RideHistoryItem(
        id: UUID(),
        startedAt: Date(),
        savingsMinorUnits: 62_000,
        distanceMeters: 4_700,
        durationSeconds: 18 * 60,
        route: []
    )
}
