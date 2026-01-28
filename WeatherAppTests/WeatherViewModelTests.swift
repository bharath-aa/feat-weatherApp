//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Bharath Kumar Kapu on 28/01/26.
//

import XCTest
@testable import WeatherApp
import CoreLocation

final class WeatherViewModelTests: XCTestCase {

    private let sampleWeather = Weather(
        cityName: "Atlanta",
        temperature: 28,
        description: "Clear sky",
        icon: "01d"
    )

    @MainActor
    func test_onAppear_loadsWeatherFromLocation_whenAuthorized() async {
        let location = CLLocation(latitude: 12.97, longitude: 77.59)

        let sut = makeSUT(
            weatherResult: .success(sampleWeather),
            locationAuthorized: true,
            locationResult: .success(location)
        )

        sut.onAppear()

        await Task.yield()

        XCTAssertEqual(sut.results.first?.city, "Atlanta")
        XCTAssertNil(sut.errorMessage)
    }

    @MainActor
    func test_onAppear_requestsAuthorization_thenLoadsLocationWeather() async {
        let location = CLLocation(latitude: 12.97, longitude: 77.59)

        let sut = makeSUT(
            weatherResult: .success(sampleWeather),
            locationAuthorized: false,
            locationResult: .success(location)
        )

        sut.onAppear()

        await Task.yield()

        XCTAssertEqual(sut.results.first?.city, "Atlanta")
    }

    @MainActor
    func test_searchTapped_addsCityResult() async {
        let sut = makeSUT(
            weatherResult: .success(sampleWeather),
            locationAuthorized: false
        )

        sut.cityInput = "Atlanta"
        sut.searchTapped()

        await Task.yield()

        XCTAssertEqual(sut.results.count, 1)
        XCTAssertEqual(sut.results.first?.city, "Atlanta")
    }


    @MainActor private func makeSUT(
        weatherResult: Result<Weather, Error>,
        locationAuthorized: Bool,
        locationResult: Result<CLLocation, Error>? = nil,
        lastCity: String? = nil
    ) -> WeatherViewModel {

        let weatherService = MockWeatherService()
        weatherService.weatherResult = weatherResult

        let locationService = MockLocationService()
        locationService.isAuthorized = locationAuthorized
        locationService.locationResult = locationResult

        let cityStore = MockLastCityStore()
        cityStore.save(lastCity ?? "")

        return WeatherViewModel(
            weatherService: weatherService,
            locationService: locationService,
            lastCityStore: cityStore
        )
    }

}
