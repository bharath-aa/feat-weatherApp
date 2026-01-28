//
//  MockLastCityStore.swift
//  WeatherApp
//
//  Created by Bharath Kumar Kapu on 28/01/26.
//
import XCTest
@testable import WeatherApp

final class MockLastCityStore: LastCityStoreProtocol {

    private(set) var savedCity: String?

    func save(_ city: String) {
        savedCity = city
    }

    func load() -> String? {
        savedCity
    }

    func clear() {
        savedCity = nil
    }
}
