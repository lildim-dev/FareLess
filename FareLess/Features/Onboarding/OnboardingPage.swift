//
//  OnboardingPage.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import Foundation

enum OnboardingPage: Int, CaseIterable, Identifiable {
    case value
    case manualRide
    case permissions

    var id: Int {
        rawValue
    }

    var titleKey: String {
        switch self {
        case .value:
            "onboarding.page1.title"
        case .manualRide:
            "onboarding.page2.title"
        case .permissions:
            "onboarding.permissions.title"
        }
    }

    var descriptionKey: String {
        switch self {
        case .value:
            "onboarding.page1.description"
        case .manualRide:
            "onboarding.page2.description"
        case .permissions:
            "onboarding.permissions.description"
        }
    }

    var symbolName: String {
        switch self {
        case .value:
            "scooter"
        case .manualRide:
            "sum"
        case .permissions:
            "lock.shield"
        }
    }

    var disclaimerKey: String? {
        switch self {
        case .manualRide:
            "onboarding.page2.disclaimer"
        case .value, .permissions:
            nil
        }
    }
}
