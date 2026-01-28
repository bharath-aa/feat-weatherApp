//
//  LocationService.swift
//  WeatherApp
//
//  Created by Bharath Kumar Kapu on 28/01/26.
//


import CoreLocation

protocol LocationServiceProtocol {
    var isAuthorized: Bool { get }
    func requestAuthorization()
    func currentLocation() async throws -> CLLocation
}

enum LocationError: LocalizedError {
    case notAuthorized
    case locationUnavailable

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Location permission is required."
        case .locationUnavailable:
            return "Unable to determine current location."
        }
    }
}

final class LocationService: NSObject, LocationServiceProtocol {

    private let manager: CLLocationManager
    private var continuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        self.manager = CLLocationManager()
        super.init()
        manager.delegate = self
    }

    var isAuthorized: Bool {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func currentLocation() async throws -> CLLocation {
        guard isAuthorized else {
            requestAuthorization()
            throw LocationError.notAuthorized
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            manager.requestLocation()
        }
    }
}

extension LocationService: CLLocationManagerDelegate {

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.first else {
            continuation?.resume(throwing: LocationError.locationUnavailable)
            continuation = nil
            return
        }

        continuation?.resume(returning: location)
        continuation = nil
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
