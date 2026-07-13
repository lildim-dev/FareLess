//
//  InMemoryRideHistoryProvider.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import Foundation

struct InMemoryRideHistoryProvider: RideHistoryProviding {
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func fetchRides() async throws -> [RideHistoryItem] {
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today

        return [
            RideHistoryItem(
                id: UUID(uuidString: "11111111-1111-1111-1111-111111111111") ?? UUID(),
                startedAt: calendar.date(byAdding: .hour, value: 9, to: today) ?? today,
                savingsMinorUnits: 62_000,
                distanceMeters: 4_700,
                durationSeconds: 18 * 60,
                route: [
                    RideRoutePoint(latitude: 55.751244, longitude: 37.618423),
                    RideRoutePoint(latitude: 55.753330, longitude: 37.624000),
                    RideRoutePoint(latitude: 55.756000, longitude: 37.630500),
                    RideRoutePoint(latitude: 55.758200, longitude: 37.637000),
                    RideRoutePoint(latitude: 55.760800, longitude: 37.642600)
                ]
            ),
            RideHistoryItem(
                id: UUID(uuidString: "22222222-2222-2222-2222-222222222222") ?? UUID(),
                startedAt: calendar.date(byAdding: .hour, value: 18, to: yesterday) ?? yesterday,
                savingsMinorUnits: 54_000,
                distanceMeters: 3_800,
                durationSeconds: 16 * 60,
                route: [
                    RideRoutePoint(latitude: 55.742000, longitude: 37.615200),
                    RideRoutePoint(latitude: 55.744100, longitude: 37.620100),
                    RideRoutePoint(latitude: 55.746600, longitude: 37.625400),
                    RideRoutePoint(latitude: 55.748800, longitude: 37.631000),
                    RideRoutePoint(latitude: 55.751000, longitude: 37.636500)
                ]
            )
        ]
    }
}
