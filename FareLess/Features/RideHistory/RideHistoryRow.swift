//
//  RideHistoryRow.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import SwiftUI

struct RideHistoryRow: View {
    let date: String
    let savings: String
    let distance: String
    let duration: String

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(date)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 8)

                    Text(savings)
                        .font(.headline)
                        .foregroundStyle(.green)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Text("\(distance) · \(duration)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
