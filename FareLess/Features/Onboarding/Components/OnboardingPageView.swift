//
//  OnboardingPageView.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: page.symbolName)
                    .font(.system(size: 60, weight: .semibold))
                    .foregroundStyle(.green)
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityLabel(Text(LocalizedStringKey("onboarding.illustration.accessibilityLabel")))

                VStack(spacing: 14) {
                    Text(LocalizedStringKey(page.titleKey))
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(LocalizedStringKey(page.descriptionKey))
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    if let disclaimerKey = page.disclaimerKey {
                        Label {
                            Text(LocalizedStringKey(disclaimerKey))
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                        } icon: {
                            Image(systemName: "info.circle")
                                .accessibilityHidden(true)
                        }
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
        }
    }
}
