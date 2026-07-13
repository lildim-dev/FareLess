//
//  PermissionRow.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import SwiftUI

struct PermissionRow: View {
    let symbolName: String
    let titleKey: String
    let descriptionKey: String
    let statusTextKey: String
    let buttonTitleKey: String
    let isRequesting: Bool
    let isButtonDisabled: Bool
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: symbolName)
                    .font(.title2)
                    .foregroundStyle(.green)
                    .frame(width: 32, height: 32)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text(LocalizedStringKey(titleKey))
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(LocalizedStringKey(descriptionKey))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(LocalizedStringKey(statusTextKey))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)
            }

            Button(action: action) {
                HStack {
                    if isRequesting {
                        ProgressView()
                            .controlSize(.small)
                    }

                    Text(LocalizedStringKey(buttonTitleKey))
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.bordered)
            .disabled(isButtonDisabled || isRequesting)
            .accessibilityLabel(Text(LocalizedStringKey(buttonTitleKey)))
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}
