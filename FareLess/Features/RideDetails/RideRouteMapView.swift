//
//  RideRouteMapView.swift
//  FareLess
//
//  Created by Codex on 13.07.2026.
//

import MapKit
import SwiftUI

struct RideRouteMapView: View {
    let coordinates: [CLLocationCoordinate2D]
    let startCoordinate: CLLocationCoordinate2D?
    let endCoordinate: CLLocationCoordinate2D?

    @State private var position: MapCameraPosition

    init(
        coordinates: [CLLocationCoordinate2D],
        startCoordinate: CLLocationCoordinate2D?,
        endCoordinate: CLLocationCoordinate2D?,
        region: MKCoordinateRegion?
    ) {
        self.coordinates = coordinates
        self.startCoordinate = startCoordinate
        self.endCoordinate = endCoordinate
        self._position = State(initialValue: region.map { .region($0) } ?? .automatic)
    }

    var body: some View {
        if coordinates.isEmpty {
            ContentUnavailableView(
                LocalizedStringKey("rideDetails.route.unavailable"),
                systemImage: "map",
                description: nil
            )
            .frame(maxWidth: .infinity)
            .frame(height: 260)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
        } else {
            Map(position: $position) {
                if coordinates.count > 1 {
                    MapPolyline(coordinates: coordinates)
                        .stroke(.green, lineWidth: 5)
                }

                if let startCoordinate {
                    Marker(
                        String(localized: "rideDetails.route.start.accessibilityLabel"),
                        systemImage: "location.fill",
                        coordinate: startCoordinate
                    )
                    .tint(.green)
                }

                if let endCoordinate {
                    Marker(
                        String(localized: "rideDetails.route.end.accessibilityLabel"),
                        systemImage: "flag.fill",
                        coordinate: endCoordinate
                    )
                    .tint(.red)
                }
            }
            .frame(height: 260)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .accessibilityLabel(Text(LocalizedStringKey("rideDetails.map.accessibilityLabel")))
        }
    }
}
