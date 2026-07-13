//
//  OnboardingCompletionStore.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import Foundation

enum OnboardingStorageKey {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
}

protocol OnboardingCompletionStoring {
    var hasCompletedOnboarding: Bool { get }
    func saveCompleted()
}

struct UserDefaultsOnboardingCompletionStore: OnboardingCompletionStoring {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var hasCompletedOnboarding: Bool {
        userDefaults.bool(forKey: OnboardingStorageKey.hasCompletedOnboarding)
    }

    func saveCompleted() {
        userDefaults.set(true, forKey: OnboardingStorageKey.hasCompletedOnboarding)
    }
}
