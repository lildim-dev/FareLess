//
//  OnboardingView.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import CoreLocation
import SwiftUI

struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel

    let onCompletion: () -> Void

    init(
        viewModel: OnboardingViewModel,
        onCompletion: @escaping () -> Void
    ) {
        self._viewModel = State(initialValue: viewModel)
        self.onCompletion = onCompletion
    }

    @MainActor
    init(onCompletion: @escaping () -> Void) {
        self._viewModel = State(initialValue: OnboardingViewModel.live())
        self.onCompletion = onCompletion
    }

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: pageSelection) {
                ForEach(viewModel.pages) { page in
                    if page == .permissions {
                        permissionsPage
                            .tag(page.rawValue)
                    } else {
                        OnboardingPageView(page: page)
                            .tag(page.rawValue)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            PageIndicator(
                pageCount: viewModel.pages.count,
                currentPageIndex: viewModel.currentPageIndex
            )
            .padding(.bottom, 16)

            Button(action: primaryAction) {
                Text(LocalizedStringKey(viewModel.primaryActionTitleKey))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(viewModel.currentPage == .permissions && !viewModel.canCompleteOnboarding)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
        .task {
            await viewModel.refreshPermissionStatuses()
        }
    }

    private var pageSelection: Binding<Int> {
        Binding(
            get: {
                viewModel.currentPageIndex
            },
            set: { newValue in
                viewModel.setCurrentPageIndex(newValue)
            }
        )
    }

    private var permissionsPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: OnboardingPage.permissions.symbolName)
                        .font(.system(size: 46, weight: .semibold))
                        .foregroundStyle(.green)
                        .accessibilityLabel(Text(LocalizedStringKey("onboarding.permissions.icon.accessibilityLabel")))

                    Text(LocalizedStringKey(OnboardingPage.permissions.titleKey))
                        .font(.largeTitle.bold())
                        .fixedSize(horizontal: false, vertical: true)

                    Text(LocalizedStringKey(OnboardingPage.permissions.descriptionKey))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                PermissionRow(
                    symbolName: "location.fill",
                    titleKey: "onboarding.permissions.location.title",
                    descriptionKey: "onboarding.permissions.location.description",
                    statusTextKey: viewModel.locationStatusTextKey,
                    buttonTitleKey: viewModel.locationRequestButtonTitleKey,
                    isRequesting: viewModel.isRequestingLocationPermission,
                    isButtonDisabled: viewModel.locationPermissionStatus == .authorized,
                    action: {
                        Task {
                            await viewModel.requestLocationPermission()
                        }
                    }
                )

                if viewModel.locationPermissionStatus == .denied || viewModel.locationPermissionStatus == .restricted {
                    Text(LocalizedStringKey("onboarding.permissions.location.deniedExplanation"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                PermissionRow(
                    symbolName: "bell.badge",
                    titleKey: "onboarding.permissions.notifications.title",
                    descriptionKey: "onboarding.permissions.notifications.description",
                    statusTextKey: viewModel.notificationStatusTextKey,
                    buttonTitleKey: viewModel.notificationRequestButtonTitleKey,
                    isRequesting: viewModel.isRequestingNotificationPermission,
                    isButtonDisabled: viewModel.notificationPermissionStatus == .authorized || viewModel.notificationPermissionStatus == .denied,
                    action: {
                        Task {
                            await viewModel.requestNotificationPermission()
                        }
                    }
                )

                Text(LocalizedStringKey("onboarding.permissions.notifications.optional"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 28)
        }
    }

    private func primaryAction() {
        if viewModel.canMoveForward {
            withAnimation {
                viewModel.moveForward()
            }
            return
        }

        guard viewModel.completeOnboarding() else {
            return
        }

        onCompletion()
    }
}

private struct PageIndicator: View {
    let pageCount: Int
    let currentPageIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(index == currentPageIndex ? Color.green : Color.secondary.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .accessibilityLabel(Text(LocalizedStringKey("onboarding.pageIndicator.accessibilityLabel")))
        .accessibilityValue(Text("\(currentPageIndex + 1) / \(pageCount)"))
    }
}

#Preview("Первая страница") {
    OnboardingView(
        viewModel: OnboardingPreviewFactory.viewModel(),
        onCompletion: {}
    )
}

#Preview("Разрешения не выданы") {
    OnboardingView(
        viewModel: OnboardingPreviewFactory.viewModel(pageIndex: 2),
        onCompletion: {}
    )
}

#Preview("Геолокация разрешена") {
    OnboardingView(
        viewModel: OnboardingPreviewFactory.viewModel(pageIndex: 2, locationStatus: .authorizedWhenInUse),
        onCompletion: {}
    )
}

#Preview("Геолокация запрещена") {
    OnboardingView(
        viewModel: OnboardingPreviewFactory.viewModel(pageIndex: 2, locationStatus: .denied),
        onCompletion: {}
    )
}

#Preview("Уведомления разрешены") {
    OnboardingView(
        viewModel: OnboardingPreviewFactory.viewModel(pageIndex: 2, notificationStatus: .authorized),
        onCompletion: {}
    )
}

#Preview("Большой текст") {
    OnboardingView(
        viewModel: OnboardingPreviewFactory.viewModel(),
        onCompletion: {}
    )
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("Тёмная тема") {
    OnboardingView(
        viewModel: OnboardingPreviewFactory.viewModel(pageIndex: 2, locationStatus: .denied),
        onCompletion: {}
    )
    .preferredColorScheme(.dark)
}

private enum OnboardingPreviewFactory {
    static func viewModel(
        pageIndex: Int = 0,
        locationStatus: CLAuthorizationStatus = .notDetermined,
        notificationStatus: NotificationPermissionStatus = .notDetermined
    ) -> OnboardingViewModel {
        let viewModel = OnboardingViewModel(
            locationPermissionProvider: PreviewLocationPermissionProvider(status: locationStatus),
            notificationPermissionProvider: PreviewNotificationPermissionProvider(status: notificationStatus),
            completionStore: PreviewOnboardingCompletionStore()
        )
        viewModel.setCurrentPageIndex(pageIndex)
        return viewModel
    }
}

private final class PreviewLocationPermissionProvider: LocationPermissionProviding {
    var authorizationStatus: CLAuthorizationStatus

    init(status: CLAuthorizationStatus) {
        self.authorizationStatus = status
    }

    func requestWhenInUseAuthorization() async {
        authorizationStatus = .authorizedWhenInUse
    }

    func openApplicationSettings() {}
}

private final class PreviewNotificationPermissionProvider: NotificationPermissionProviding {
    private var status: NotificationPermissionStatus

    init(status: NotificationPermissionStatus) {
        self.status = status
    }

    func authorizationStatus() async -> NotificationPermissionStatus {
        status
    }

    func requestAuthorization() async -> Bool {
        status = .authorized
        return true
    }
}

private final class PreviewOnboardingCompletionStore: OnboardingCompletionStoring {
    var hasCompletedOnboarding = false

    func saveCompleted() {
        hasCompletedOnboarding = true
    }
}
