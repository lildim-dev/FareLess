//
//  RideResultView.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import SwiftUI

struct RideResultView: View {
    @State private var viewModel: RideResultViewModel

    init(viewModel: RideResultViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    savingsCard

                    HStack(spacing: 12) {
                        RideResultMetricCard(
                            titleKey: "rideResult.distance.title",
                            value: viewModel.formattedDistance
                        )

                        RideResultMetricCard(
                            titleKey: "rideResult.duration.title",
                            value: viewModel.formattedDuration
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }

            doneButton
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .background(.bar)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var savingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedStringKey("rideResult.savings.title"))
                .font(.headline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(viewModel.formattedSavings)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
    }

    private var doneButton: some View {
        Button {
            viewModel.done()
        } label: {
            Text(LocalizedStringKey("rideResult.done"))
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 56)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .accessibilityLabel(Text(LocalizedStringKey("rideResult.done")))
    }
}

private struct RideResultMetricCard: View {
    let titleKey: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(titleKey))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(value)
                .font(.title2.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
    }
}

#Preview("Ride Result") {
    NavigationStack {
        RideResultView(
            viewModel: RideResultViewModel(
                snapshot: .demo,
                onDone: {}
            )
        )
        .navigationTitle(LocalizedStringKey("rideResult.navigation.title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Dark") {
    NavigationStack {
        RideResultView(
            viewModel: RideResultViewModel(
                snapshot: .demo,
                onDone: {}
            )
        )
        .navigationTitle(LocalizedStringKey("rideResult.navigation.title"))
        .navigationBarTitleDisplayMode(.inline)
    }
    .preferredColorScheme(.dark)
}
