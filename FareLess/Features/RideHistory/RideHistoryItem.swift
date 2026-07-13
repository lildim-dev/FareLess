//
//  RideHistoryItem.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import Foundation

struct RideHistoryItem: Identifiable, Hashable {
    let id: UUID
    let startedAt: Date
    let taxiPriceMinorUnits: Int
    let savingsMinorUnits: Int
    let distanceMeters: Double
    let durationSeconds: TimeInterval
    let route: [RideRoutePoint]
}

struct RideRoutePoint: Hashable {
    let latitude: Double
    let longitude: Double
}
