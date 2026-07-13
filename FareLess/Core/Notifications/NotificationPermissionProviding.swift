//
//  NotificationPermissionProviding.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import UserNotifications

enum NotificationPermissionStatus: Equatable {
    case notDetermined
    case requesting
    case authorized
    case denied
    case restricted
    case unknown
    case failed
}

protocol NotificationPermissionProviding: AnyObject {
    func authorizationStatus() async -> NotificationPermissionStatus
    func requestAuthorization() async -> Bool
}

final class NotificationPermissionProvider: NotificationPermissionProviding {
    private let notificationCenter: UNUserNotificationCenter

    init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
    }

    func authorizationStatus() async -> NotificationPermissionStatus {
        let settings = await notificationCenter.notificationSettings()
        return NotificationPermissionStatus(settingsAuthorizationStatus: settings.authorizationStatus)
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }
}

extension NotificationPermissionStatus {
    init(settingsAuthorizationStatus: UNAuthorizationStatus) {
        switch settingsAuthorizationStatus {
        case .notDetermined:
            self = .notDetermined
        case .denied:
            self = .denied
        case .authorized, .provisional, .ephemeral:
            self = .authorized
        @unknown default:
            self = .unknown
        }
    }
}
