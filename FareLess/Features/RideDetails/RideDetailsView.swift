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
                    finishCoordinate: viewModel.finishCoordinate,
                    position: viewModel.mapPosition
                )

                RideDetailsInformationCard(viewModel: viewModel)
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(LocalizedStringKey("rideDetails.navigation.title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct RideDetailsInformationCard: View {
    let viewModel: RideDetailsViewModel

    var body: some View {
        VStack(spacing: 0) {
            RideDetailRow(
                title: "rideDetails.date.title",
                value: viewModel.formattedDate
            )
            Divider()
            RideDetailRow(
                title: "rideDetails.distance.title",
                value: viewModel.formattedDistance
            )
            Divider()
            RideDetailRow(
                title: "rideDetails.duration.title",
                value: viewModel.formattedDuration
            )
            Divider()
            RideDetailRow(
                title: "rideDetails.taxiPrice.title",
                value: viewModel.formattedTaxiPrice
            )
            Divider()
                .padding(.top, 6)
            RideDetailRow(
                title: "rideDetails.savings.title",
                value: viewModel.formattedSavings,
                isHighlighted: true
            )
            .padding(.top, 6)
        }
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct RideDetailRow: View {
    let title: LocalizedStringKey
    let value: String
    var isHighlighted = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(title)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 8)

            Text(value)
                .font(isHighlighted ? .title3.bold() : .body.weight(.semibold))
                .foregroundStyle(isHighlighted ? Color.green : Color.primary)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityValue(Text(value))
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

#Preview("Одна точка") {
    NavigationStack {
        RideDetailsView(
            viewModel: RideDetailsViewModel(
                ride: RideDetailsPreviewFactory.rideWithSinglePoint
            )
        )
    }
}

#Preview("Большой текст") {
    NavigationStack {
        RideDetailsView(
            viewModel: RideDetailsViewModel(
                ride: RideDetailsPreviewFactory.rideWithLongValues
            )
        )
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("Тёмная тема") {
    NavigationStack {
        RideDetailsView(
            viewModel: RideDetailsViewModel(
                ride: RideDetailsPreviewFactory.rideWithRoute
            )
        )
    }
    .preferredColorScheme(.dark)
}

private enum RideDetailsPreviewFactory {
    static let rideWithRoute = RideHistoryItem(
        id: UUID(),
        startedAt: Date(),
        taxiPriceMinorUnits: 62_000,
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
        taxiPriceMinorUnits: 62_000,
        savingsMinorUnits: 62_000,
        distanceMeters: 4_700,
        durationSeconds: 18 * 60,
        route: []
    )

    static let rideWithSinglePoint = RideHistoryItem(
        id: UUID(),
        startedAt: Date(),
        taxiPriceMinorUnits: 62_000,
        savingsMinorUnits: 62_000,
        distanceMeters: 400,
        durationSeconds: 6 * 60,
        route: [
            RideRoutePoint(latitude: 55.751244, longitude: 37.618423)
        ]
    )

    static let rideWithLongValues = RideHistoryItem(
        id: UUID(),
        startedAt: Date(),
        taxiPriceMinorUnits: 1_234_567_00,
        savingsMinorUnits: 1_234_567_00,
        distanceMeters: 124_700,
        durationSeconds: 2 * 60 * 60 + 35 * 60,
        route: [
            RideRoutePoint(latitude: 55.751244, longitude: 37.618423),
            RideRoutePoint(latitude: 55.753330, longitude: 37.624000),
            RideRoutePoint(latitude: 55.756000, longitude: 37.630500),
            RideRoutePoint(latitude: 55.758200, longitude: 37.637000)
        ]
    )
}
