//
//  ActiveRideViewModel.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class ActiveRideViewModel {
    private(set) var snapshot: ActiveRideSnapshot
    private let onFinish: () -> Void

    init(
        snapshot: ActiveRideSnapshot = ActiveRideSnapshot(
            elapsedTime: String(localized: "activeRide.demo.elapsedTime"),
            distance: String(localized: "activeRide.demo.distance"),
            status: String(localized: "activeRide.demo.status")
        ),
        onFinish: @escaping () -> Void = {}
    ) {
        self.snapshot = snapshot
        self.onFinish = onFinish
    }

    func finishRide() {
        onFinish()
    }
}
