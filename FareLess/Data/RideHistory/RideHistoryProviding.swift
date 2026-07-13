//
//  RideHistoryProviding.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import Foundation

protocol RideHistoryProviding {
    func fetchRides() async throws -> [RideHistoryItem]
}
