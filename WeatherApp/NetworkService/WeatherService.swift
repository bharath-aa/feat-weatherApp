//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Bharath Kumar Kapu on 28/01/26.
//

import Foundation

enum WeatherError: LocalizedError {
    case invalidResponse
    case apiFailure(statusCode: Int)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Unexpected server response."
        case .apiFailure:
            return "Unable to fetch weather data. Please try again."
        case .decodingFailed:
            return "Failed to read weather information."
        }
    }
}


protocol WeatherServiceProtocol {
    func fetchWeather(city: String) async throws -> Weather
    func fetchWeather(lat: Double, lon: Double) async throws -> Weather
}

final class WeatherService: WeatherServiceProtocol {

    private let apiKey: String
    private let session: URLSession

    init(
        apiKey: String,
        session: URLSession = .shared
    ) {
        self.apiKey = apiKey
        self.session = session
    }

    func fetchWeather(city: String) async throws -> Weather {
        // NOTE: City-based API is deprecated but still supported.
        // For production, we would first geocode city -> coordinates.
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let url = buildURL(queryItems: [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "units", value: "metric")
        ])
        return try await performRequest(url: url)
    }

    func fetchWeather(lat: Double, lon: Double) async throws -> Weather {
        let url = buildURL(queryItems: [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)"),
            URLQueryItem(name: "units", value: "metric")
        ])
        return try await performRequest(url: url)
    }

    // MARK: - Private Helpers

    private func buildURL(queryItems: [URLQueryItem]) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"

        var items = queryItems
        items.append(URLQueryItem(name: "appid", value: apiKey))
        components.queryItems = items

        // Safe unwrap since components are deterministic
        return components.url!
    }

    private func performRequest(url: URL) async throws -> Weather {
        let (data, response) = try await session.data(from: url)

        guard let http = response as? HTTPURLResponse else {
            throw WeatherError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw WeatherError.apiFailure(statusCode: http.statusCode)
        }

        do {
            let dto = try JSONDecoder().decode(WeatherResponseDTO.self, from: data)
            return try Weather(dto: dto)
        } catch let error as WeatherMappingError {
            throw error
        } catch {
            throw WeatherError.decodingFailed
        }
    }
}
