//
//  RideDetailsViewModel.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import Foundation
import MapKit
import Observation

@MainActor
@Observable
final class RideDetailsViewModel {
    let ride: RideHistoryItem

    init(ride: RideHistoryItem) {
        self.ride = ride
    }

    var formattedSavings: String {
        CurrencyFormatter.formattedMinorUnits(ride.savingsMinorUnits, currencyCode: "RUB")
    }

    var formattedDistance: String {
        RideHistoryFormatters.distance(ride.distanceMeters)
    }

    var formattedDuration: String {
        RideHistoryFormatters.duration(ride.durationSeconds)
    }

    var formattedDate: String {
        ride.startedAt.formatted(date: .abbreviated, time: .shortened)
    }

    var routeCoordinates: [CLLocationCoordinate2D] {
        ride.route.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }
    }

    var startCoordinate: CLLocationCoordinate2D? {
        routeCoordinates.first
    }

    var endCoordinate: CLLocationCoordinate2D? {
        routeCoordinates.last
    }

    var mapRegion: MKCoordinateRegion? {
        let coordinates = routeCoordinates

        guard let firstCoordinate = coordinates.first else {
            return nil
        }

        guard coordinates.count > 1 else {
            return MKCoordinateRegion(
                center: firstCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }

        let latitudes = coordinates.map(\.latitude)
        let longitudes = coordinates.map(\.longitude)

        guard
            let minLatitude = latitudes.min(),
            let maxLatitude = latitudes.max(),
            let minLongitude = longitudes.min(),
            let maxLongitude = longitudes.max()
        else {
            return nil
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLatitude + maxLatitude) / 2,
            longitude: (minLongitude + maxLongitude) / 2
        )
        let latitudeDelta = max((maxLatitude - minLatitude) * 1.5, 0.01)
        let longitudeDelta = max((maxLongitude - minLongitude) * 1.5, 0.01)

        return MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        )
    }
}
