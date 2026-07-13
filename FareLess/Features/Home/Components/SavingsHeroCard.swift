//
//  SavingsHeroCard.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import SwiftUI

struct SavingsHeroCard: View {
    let amount: String
    let accessibilityAmount: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(LocalizedStringKey("home.savings.today.title"))
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                Image(systemName: "banknote")
                    .font(.title2)
                    .foregroundStyle(.green)
                    .accessibilityHidden(true)
            }

            Text(amount)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .contentTransition(.numericText())
                .accessibilityHidden(true)

            Text(LocalizedStringKey("home.savings.today.subtitle"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(LocalizedStringKey("home.savings.today.accessibilityLabel")))
        .accessibilityValue(Text(accessibilityAmount))
    }
}
