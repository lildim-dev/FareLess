//
//  RideResultSnapshot.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import Foundation

struct RideResultSnapshot: Equatable {
    let savingsMinorUnits: Int
    let distanceMeters: Double
    let durationSeconds: TimeInterval

    static let demo = RideResultSnapshot(
        savingsMinorUnits: 62_000,
        distanceMeters: 4_700,
        durationSeconds: 18 * 60
    )
}
