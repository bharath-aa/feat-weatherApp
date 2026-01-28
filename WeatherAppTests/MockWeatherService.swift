//
//  MockWeatherService.swift
//  WeatherApp
//
//  Created by Bharath Kumar Kapu on 28/01/26.
//
import XCTest
@testable import WeatherApp

final class MockWeatherService: WeatherServiceProtocol {

    var weatherResult: Result<Weather, Error>!

    func fetchWeather(city: String) async throws -> Weather {
        try weatherResult.get()
    }

    func fetchWeather(lat: Double, lon: Double) async throws -> Weather {
        try weatherResult.get()
    }
}
