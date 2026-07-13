//
//  SavingsMetricView.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import SwiftUI

struct SavingsMetricView: View {
    let titleKey: String
    let amount: String
    let accessibilityLabelKey: String
    let accessibilityAmount: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(titleKey))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(amount)
                .font(.title2.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(LocalizedStringKey(accessibilityLabelKey)))
        .accessibilityValue(Text(accessibilityAmount))
    }
}
