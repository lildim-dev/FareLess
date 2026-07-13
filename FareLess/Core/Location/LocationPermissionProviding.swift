//
//  LocationPermissionProviding.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import CoreLocation
import UIKit

enum PermissionAuthorizationStatus: Equatable {
    case notDetermined
    case requesting
    case authorized
    case denied
    case restricted
    case unknown
    case failed
}

protocol LocationPermissionProviding: AnyObject {
    var authorizationStatus: CLAuthorizationStatus { get }
    func requestWhenInUseAuthorization() async
    func openApplicationSettings()
}

final class LocationPermissionProvider: NSObject, LocationPermissionProviding {
    private let locationManager: CLLocationManager
    private var continuations: [CheckedContinuation<Void, Never>] = []

    init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
    }

    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }

    func requestWhenInUseAuthorization() async {
        guard authorizationStatus == .notDetermined else {
            return
        }

        await withCheckedContinuation { continuation in
            continuations.append(continuation)
            locationManager.requestWhenInUseAuthorization()
        }
    }

    @MainActor
    func openApplicationSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        UIApplication.shared.open(settingsURL)
    }
}

extension LocationPermissionProvider: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let pendingContinuations = continuations
        continuations.removeAll()
        pendingContinuations.forEach { $0.resume() }
    }
}

extension PermissionAuthorizationStatus {
    init(clAuthorizationStatus: CLAuthorizationStatus) {
        switch clAuthorizationStatus {
        case .notDetermined:
            self = .notDetermined
        case .restricted:
            self = .restricted
        case .denied:
            self = .denied
        case .authorizedAlways, .authorizedWhenInUse:
            self = .authorized
        @unknown default:
            self = .unknown
        }
    }
}
