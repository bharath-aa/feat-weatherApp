//
//  MockLocationService.swift
//  WeatherApp
//
//  Created by Bharath Kumar Kapu on 28/01/26.
//
import XCTest
@testable import WeatherApp
import CoreLocation

final class MockLocationService: LocationServiceProtocol {

    var isAuthorized: Bool = false
    var onAuthorizationGranted: (() -> Void)?
    var locationResult: Result<CLLocation, Error>!

    func requestAuthorization() {
        // Simulate user granting permission
        isAuthorized = true
        onAuthorizationGranted?()
    }

    func currentLocation() async throws -> CLLocation {
        try locationResult.get()
    }
}
