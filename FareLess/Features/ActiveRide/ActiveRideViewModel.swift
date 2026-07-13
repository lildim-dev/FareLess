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

    init(
        snapshot: ActiveRideSnapshot = ActiveRideSnapshot(
            elapsedTime: String(localized: "activeRide.demo.elapsedTime"),
            distance: String(localized: "activeRide.demo.distance"),
            status: String(localized: "activeRide.demo.status")
        )
    ) {
        self.snapshot = snapshot
    }

    func finishRide() {
        // TODO: Complete the ride and navigate to the ride result screen when trip tracking is implemented.
    }
}
