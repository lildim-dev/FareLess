//
//  ActiveRideView.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import SwiftUI

struct ActiveRideView: View {
    @State private var viewModel: ActiveRideViewModel

    init(viewModel: ActiveRideViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    @MainActor
    init() {
        self._viewModel = State(initialValue: ActiveRideViewModel())
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 18) {
                    ActiveRideMetricCard(
                        titleKey: "activeRide.elapsedTime.title",
                        value: viewModel.snapshot.elapsedTime,
                        symbolName: "clock"
                    )

                    ActiveRideMetricCard(
                        titleKey: "activeRide.distance.title",
                        value: viewModel.snapshot.distance,
                        symbolName: "point.topleft.down.curvedto.point.bottomright.up"
                    )

                    ActiveRideStatusCard(status: viewModel.snapshot.status)
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }

            finishButton
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .background(.bar)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var finishButton: some View {
        Button {
            viewModel.finishRide()
        } label: {
            Text(LocalizedStringKey("activeRide.finish"))
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 56)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .accessibilityLabel(Text(LocalizedStringKey("activeRide.finish")))
    }
}

private struct ActiveRideMetricCard: View {
    let titleKey: String
    let value: String
    let symbolName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(LocalizedStringKey(titleKey))
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Image(systemName: symbolName)
                    .font(.title3)
                    .foregroundStyle(.green)
                    .accessibilityHidden(true)
            }

            Text(value)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
    }
}

private struct ActiveRideStatusCard: View {
    let status: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(LocalizedStringKey("activeRide.status.title"))
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                Image(systemName: "record.circle")
                    .font(.title3)
                    .foregroundStyle(.green)
                    .accessibilityHidden(true)
            }

            Text(status)
                .font(.title2.bold())
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
    }
}

#Preview("Active Ride") {
    NavigationStack {
        ActiveRideView()
            .navigationTitle(LocalizedStringKey("activeRide.navigation.title"))
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Dark") {
    NavigationStack {
        ActiveRideView()
            .navigationTitle(LocalizedStringKey("activeRide.navigation.title"))
            .navigationBarTitleDisplayMode(.inline)
    }
    .preferredColorScheme(.dark)
}

#Preview("Large Text") {
    NavigationStack {
        ActiveRideView()
            .navigationTitle(LocalizedStringKey("activeRide.navigation.title"))
            .navigationBarTitleDisplayMode(.inline)
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}
