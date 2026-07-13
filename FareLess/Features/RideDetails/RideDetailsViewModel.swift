//
//  RideDetailsViewModel.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import Foundation
import MapKit
import Observation
import SwiftUI

@MainActor
@Observable
final class RideDetailsViewModel {
    let ride: RideHistoryItem
    private let calendar: Calendar

    init(
        ride: RideHistoryItem,
        calendar: Calendar = .current
    ) {
        self.ride = ride
        self.calendar = calendar
    }

    var formattedSavings: String {
        CurrencyFormatter.formattedMinorUnits(ride.savingsMinorUnits, currencyCode: "RUB")
    }

    var formattedTaxiPrice: String {
        CurrencyFormatter.formattedMinorUnits(ride.taxiPriceMinorUnits, currencyCode: "RUB")
    }

    var formattedDistance: String {
        RideHistoryFormatters.distance(ride.distanceMeters)
    }

    var formattedDuration: String {
        RideHistoryFormatters.duration(ride.durationSeconds)
    }

    var formattedDate: String {
        let time = ride.startedAt.formatted(date: .omitted, time: .shortened)

        if calendar.isDateInToday(ride.startedAt) {
            return String(format: String(localized: "rideDetails.date.todayFormat"), time)
        }

        if calendar.isDateInYesterday(ride.startedAt) {
            return String(format: String(localized: "rideDetails.date.yesterdayFormat"), time)
        }

        return ride.startedAt.formatted(date: .long, time: .shortened)
    }

    var routeCoordinates: [CLLocationCoordinate2D] {
        ride.route.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }
    }

    var startCoordinate: CLLocationCoordinate2D? {
        routeCoordinates.first
    }

    var finishCoordinate: CLLocationCoordinate2D? {
        routeCoordinates.last
    }

    var mapPosition: MapCameraPosition {
        guard let region = mapRegion else {
            return .automatic
        }

        return .region(region)
    }

    private var mapRegion: MKCoordinateRegion? {
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
