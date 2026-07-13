//
//  OnboardingViewModel.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class OnboardingViewModel {
    private let locationPermissionProvider: LocationPermissionProviding
    private let notificationPermissionProvider: NotificationPermissionProviding
    private let completionStore: OnboardingCompletionStoring

    private(set) var currentPageIndex = 0
    private(set) var locationPermissionStatus: PermissionAuthorizationStatus
    private(set) var notificationPermissionStatus: NotificationPermissionStatus = .notDetermined

    let pages = OnboardingPage.allCases

    init(
        locationPermissionProvider: LocationPermissionProviding,
        notificationPermissionProvider: NotificationPermissionProviding,
        completionStore: OnboardingCompletionStoring
    ) {
        self.locationPermissionProvider = locationPermissionProvider
        self.notificationPermissionProvider = notificationPermissionProvider
        self.completionStore = completionStore
        self.locationPermissionStatus = PermissionAuthorizationStatus(
            clAuthorizationStatus: locationPermissionProvider.authorizationStatus
        )
    }

    static func live() -> OnboardingViewModel {
        OnboardingViewModel(
            locationPermissionProvider: LocationPermissionProvider(),
            notificationPermissionProvider: NotificationPermissionProvider(),
            completionStore: UserDefaultsOnboardingCompletionStore()
        )
    }

    var currentPage: OnboardingPage {
        pages[currentPageIndex]
    }

    var canMoveForward: Bool {
        currentPageIndex < pages.count - 1
    }

    var canCompleteOnboarding: Bool {
        locationPermissionStatus == .authorized
    }

    var isRequestingLocationPermission: Bool {
        locationPermissionStatus == .requesting
    }

    var isRequestingNotificationPermission: Bool {
        notificationPermissionStatus == .requesting
    }

    var locationStatusTextKey: String {
        statusTextKey(for: locationPermissionStatus)
    }

    var notificationStatusTextKey: String {
        statusTextKey(for: notificationPermissionStatus)
    }

    var primaryActionTitleKey: String {
        canMoveForward ? "onboarding.action.next" : "onboarding.action.start"
    }

    var locationRequestButtonTitleKey: String {
        switch locationPermissionStatus {
        case .denied, .restricted:
            "onboarding.action.openSettings"
        case .authorized:
            "onboarding.permission.status.authorized"
        case .requesting:
            "onboarding.permission.status.requesting"
        case .notDetermined, .unknown, .failed:
            "onboarding.action.allow"
        }
    }

    var notificationRequestButtonTitleKey: String {
        switch notificationPermissionStatus {
        case .authorized:
            "onboarding.permission.status.authorized"
        case .denied, .restricted:
            "onboarding.action.skip"
        case .requesting:
            "onboarding.permission.status.requesting"
        case .notDetermined, .unknown, .failed:
            "onboarding.action.allow"
        }
    }

    func refreshPermissionStatuses() async {
        locationPermissionStatus = PermissionAuthorizationStatus(
            clAuthorizationStatus: locationPermissionProvider.authorizationStatus
        )
        notificationPermissionStatus = await notificationPermissionProvider.authorizationStatus()
    }

    func moveForward() {
        guard canMoveForward else {
            return
        }

        currentPageIndex += 1
    }

    func setCurrentPageIndex(_ index: Int) {
        guard pages.indices.contains(index) else {
            return
        }

        currentPageIndex = index
    }

    func requestLocationPermission() async {
        guard !isRequestingLocationPermission else {
            return
        }

        switch locationPermissionStatus {
        case .denied, .restricted:
            locationPermissionProvider.openApplicationSettings()
        case .notDetermined, .unknown, .failed:
            locationPermissionStatus = .requesting
            await locationPermissionProvider.requestWhenInUseAuthorization()
            locationPermissionStatus = PermissionAuthorizationStatus(
                clAuthorizationStatus: locationPermissionProvider.authorizationStatus
            )
        case .authorized, .requesting:
            break
        }
    }

    func requestNotificationPermission() async {
        guard !isRequestingNotificationPermission else {
            return
        }

        switch notificationPermissionStatus {
        case .notDetermined, .unknown, .failed:
            notificationPermissionStatus = .requesting
            let isAuthorized = await notificationPermissionProvider.requestAuthorization()
            notificationPermissionStatus = isAuthorized ? .authorized : await notificationPermissionProvider.authorizationStatus()
        case .authorized, .denied, .restricted, .requesting:
            break
        }
    }

    @discardableResult
    func completeOnboarding() -> Bool {
        guard canCompleteOnboarding else {
            return false
        }

        completionStore.saveCompleted()
        return true
    }

    private func statusTextKey(for status: PermissionAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            "onboarding.permission.status.notDetermined"
        case .requesting:
            "onboarding.permission.status.requesting"
        case .authorized:
            "onboarding.permission.status.authorized"
        case .denied:
            "onboarding.permission.status.denied"
        case .restricted:
            "onboarding.permission.status.restricted"
        case .unknown, .failed:
            "onboarding.permission.status.failed"
        }
    }

    private func statusTextKey(for status: NotificationPermissionStatus) -> String {
        switch status {
        case .notDetermined:
            "onboarding.permission.status.notDetermined"
        case .requesting:
            "onboarding.permission.status.requesting"
        case .authorized:
            "onboarding.permission.status.authorized"
        case .denied:
            "onboarding.permission.status.denied"
        case .restricted:
            "onboarding.permission.status.restricted"
        case .unknown, .failed:
            "onboarding.permission.status.failed"
        }
    }
}
