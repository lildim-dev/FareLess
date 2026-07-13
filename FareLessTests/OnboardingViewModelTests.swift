//
//  OnboardingViewModelTests.swift
//  FareLessTests
//
//  Created by Codex on 13.07.2026.
//

import CoreLocation
import Testing
@testable import FareLess

@MainActor
struct OnboardingViewModelTests {
    @Test func initialPageIndexIsZero() {
        let viewModel = makeViewModel()

        #expect(viewModel.currentPageIndex == 0)
    }

    @Test func movingForwardChangesCurrentPage() {
        let viewModel = makeViewModel()

        viewModel.moveForward()

        #expect(viewModel.currentPageIndex == 1)
    }

    @Test func cannotCompleteWithoutLocationPermission() {
        let completionStore = MockOnboardingCompletionStore()
        let viewModel = makeViewModel(
            locationStatus: .notDetermined,
            completionStore: completionStore
        )

        let didComplete = viewModel.completeOnboarding()

        #expect(didComplete == false)
        #expect(completionStore.hasCompletedOnboarding == false)
    }

    @Test func canCompleteWithLocationPermissionAndDeniedNotifications() async {
        let completionStore = MockOnboardingCompletionStore()
        let viewModel = makeViewModel(
            locationStatus: .authorizedWhenInUse,
            notificationStatus: .denied,
            completionStore: completionStore
        )
        await viewModel.refreshPermissionStatuses()

        let didComplete = viewModel.completeOnboarding()

        #expect(didComplete == true)
        #expect(completionStore.hasCompletedOnboarding == true)
    }

    @Test func requestingLocationUpdatesState() async {
        let locationProvider = MockLocationPermissionProvider(
            initialStatus: .notDetermined,
            requestedStatus: .authorizedWhenInUse
        )
        let viewModel = makeViewModelWithMocks(locationProvider: locationProvider)

        await viewModel.requestLocationPermission()

        #expect(viewModel.locationPermissionStatus == .authorized)
        #expect(locationProvider.requestCount == 1)
        #expect(locationProvider.didTouchSystemAPI == false)
    }

    @Test func requestingNotificationsUpdatesState() async {
        let notificationProvider = MockNotificationPermissionProvider(
            initialStatus: .notDetermined,
            requestedStatus: .authorized
        )
        let viewModel = makeViewModelWithMocks(notificationProvider: notificationProvider)

        await viewModel.requestNotificationPermission()

        #expect(viewModel.notificationPermissionStatus == .authorized)
        #expect(notificationProvider.requestCount == 1)
        #expect(notificationProvider.didTouchSystemAPI == false)
    }

    @Test func repeatedTapDuringLocationRequestDoesNotStartSecondRequest() async {
        let locationProvider = MockLocationPermissionProvider(
            initialStatus: .notDetermined,
            requestedStatus: .authorizedWhenInUse,
            suspendsRequest: true
        )
        let viewModel = makeViewModelWithMocks(locationProvider: locationProvider)

        let firstRequest = Task {
            await viewModel.requestLocationPermission()
        }
        await Task.yield()

        let secondRequest = Task {
            await viewModel.requestLocationPermission()
        }
        await Task.yield()

        #expect(locationProvider.requestCount == 1)

        locationProvider.finishSuspendedRequest()
        await firstRequest.value
        await secondRequest.value
    }

    @Test func completionSavesFlag() {
        let completionStore = MockOnboardingCompletionStore()
        let viewModel = makeViewModel(
            locationStatus: .authorizedWhenInUse,
            completionStore: completionStore
        )

        _ = viewModel.completeOnboarding()

        #expect(completionStore.hasCompletedOnboarding == true)
        #expect(completionStore.saveCompletedCallCount == 1)
    }

    @Test func mocksDoNotCallRealSystemAPIs() async {
        let locationProvider = MockLocationPermissionProvider(
            initialStatus: .notDetermined,
            requestedStatus: .authorizedWhenInUse
        )
        let notificationProvider = MockNotificationPermissionProvider(
            initialStatus: .notDetermined,
            requestedStatus: .authorized
        )
        let viewModel = makeViewModelWithMocks(
            locationProvider: locationProvider,
            notificationProvider: notificationProvider
        )

        await viewModel.requestLocationPermission()
        await viewModel.requestNotificationPermission()

        #expect(locationProvider.didTouchSystemAPI == false)
        #expect(notificationProvider.didTouchSystemAPI == false)
    }

    private func makeViewModel(
        locationStatus: CLAuthorizationStatus = .notDetermined,
        notificationStatus: NotificationPermissionStatus = .notDetermined,
        completionStore: MockOnboardingCompletionStore = MockOnboardingCompletionStore()
    ) -> OnboardingViewModel {
        makeViewModelWithMocks(
            locationProvider: MockLocationPermissionProvider(initialStatus: locationStatus),
            notificationProvider: MockNotificationPermissionProvider(initialStatus: notificationStatus),
            completionStore: completionStore
        )
    }

    private func makeViewModelWithMocks(
        locationProvider: MockLocationPermissionProvider = MockLocationPermissionProvider(initialStatus: .notDetermined),
        notificationProvider: MockNotificationPermissionProvider = MockNotificationPermissionProvider(initialStatus: .notDetermined),
        completionStore: MockOnboardingCompletionStore = MockOnboardingCompletionStore()
    ) -> OnboardingViewModel {
        OnboardingViewModel(
            locationPermissionProvider: locationProvider,
            notificationPermissionProvider: notificationProvider,
            completionStore: completionStore
        )
    }
}

private final class MockLocationPermissionProvider: LocationPermissionProviding {
    var authorizationStatus: CLAuthorizationStatus
    private let requestedStatus: CLAuthorizationStatus
    private let suspendsRequest: Bool
    private var continuation: CheckedContinuation<Void, Never>?

    private(set) var requestCount = 0
    private(set) var didOpenSettings = false
    let didTouchSystemAPI = false

    init(
        initialStatus: CLAuthorizationStatus,
        requestedStatus: CLAuthorizationStatus = .authorizedWhenInUse,
        suspendsRequest: Bool = false
    ) {
        self.authorizationStatus = initialStatus
        self.requestedStatus = requestedStatus
        self.suspendsRequest = suspendsRequest
    }

    func requestWhenInUseAuthorization() async {
        requestCount += 1

        if suspendsRequest {
            await withCheckedContinuation { continuation in
                self.continuation = continuation
            }
        }

        authorizationStatus = requestedStatus
    }

    func openApplicationSettings() {
        didOpenSettings = true
    }

    func finishSuspendedRequest() {
        continuation?.resume()
        continuation = nil
    }
}

private final class MockNotificationPermissionProvider: NotificationPermissionProviding {
    private var status: NotificationPermissionStatus
    private let requestedStatus: NotificationPermissionStatus

    private(set) var requestCount = 0
    let didTouchSystemAPI = false

    init(
        initialStatus: NotificationPermissionStatus,
        requestedStatus: NotificationPermissionStatus = .authorized
    ) {
        self.status = initialStatus
        self.requestedStatus = requestedStatus
    }

    func authorizationStatus() async -> NotificationPermissionStatus {
        status
    }

    func requestAuthorization() async -> Bool {
        requestCount += 1
        status = requestedStatus
        return requestedStatus == .authorized
    }
}

private final class MockOnboardingCompletionStore: OnboardingCompletionStoring {
    private(set) var hasCompletedOnboarding = false
    private(set) var saveCompletedCallCount = 0

    func saveCompleted() {
        saveCompletedCallCount += 1
        hasCompletedOnboarding = true
    }
}
