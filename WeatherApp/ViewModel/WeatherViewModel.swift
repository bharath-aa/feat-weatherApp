//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Bharath Kumar Kapu on 28/01/26.
//
import Foundation
import CoreLocation
import Combine

@MainActor
final class WeatherViewModel: ObservableObject {

    @Published var cityInput: String = ""
    enum ScreenState: Equatable {
        case initial
        case content
        case error(String)
    }

    @Published private(set) var screenState: ScreenState = .initial
    @Published private(set) var results: [WeatherDisplayModel] = []
    @Published private(set) var currentLocationModel: WeatherDisplayModel?
    @Published private(set) var recentResults: [WeatherDisplayModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Dependencies
    private let weatherService: WeatherServiceProtocol
    private let locationService: LocationServiceProtocol
    private let lastCityStore: LastCityStoreProtocol

    // MARK: - Init
    init(
        weatherService: WeatherServiceProtocol,
        locationService: LocationServiceProtocol,
        lastCityStore: LastCityStoreProtocol = UserDefaultsLastCityStore()
    ) {
        self.weatherService = weatherService
        self.locationService = locationService
        self.lastCityStore = lastCityStore
    }

    // MARK: - Lifecycle
    func onAppear() {
        // Show both: current location (if authorized) and previously searched city (if any)
        screenState = .initial
        errorMessage = nil

        if let lastCity = lastCityStore.load(), lastCity.isEmpty == false {
            fetchRecent(city: lastCity)
        }

        if locationService.isAuthorized {
            loadWeatherForCurrentLocation()
        } else {
            locationService.requestAuthorization()
        }
    }

    // MARK: - User Actions
    func searchTapped() {
        let city = cityInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !city.isEmpty else { return }

        fetchRecentAndStore(city: city)
        cityInput = ""
    }

    private func fetchRecentAndStore(city: String) {
        isLoading = true
        errorMessage = nil
        screenState = .initial
        lastCityStore.save(city)

        Task {
            do {
                let weather = try await weatherService.fetchWeather(city: city)
                insertRecent(weather)
                screenState = .content
            } catch {
                errorMessage = error.localizedDescription
                screenState = .error(error.localizedDescription)
            }
            isLoading = false
        }
    }

    private func fetchRecent(city: String) {
        Task {
            do {
                let weather = try await weatherService.fetchWeather(city: city)
                insertRecent(weather)
            } catch {
              // no-op
            }
        }
    }

    private func loadWeatherForCurrentLocation() {
        isLoading = true
        errorMessage = nil
        screenState = .initial

        Task {
            do {
                let location = try await locationService.currentLocation()
                let weather = try await weatherService.fetchWeather(
                    lat: location.coordinate.latitude,
                    lon: location.coordinate.longitude
                )

                // Do not override last searched city with current location
                currentLocationModel = WeatherDisplayModel(from: weather)
                rebuildResults()
                screenState = .content

            } catch {
                // Graceful fallback
                if let lastCity = lastCityStore.load(), lastCity.isEmpty == false {
                    fetchRecent(city: lastCity)
                } else {
                    errorMessage = "Unable to determine your location."
                    screenState = .error("Unable to determine your location.")
                }
            }
            isLoading = false
        }
    }

    private func insertRecent(_ weather: Weather) {
        let model = WeatherDisplayModel(from: weather)
        // Avoid duplicates in recents
        recentResults.removeAll { $0.city.lowercased() == model.city.lowercased() }
        recentResults.insert(model, at: 0)
        rebuildResults()
        screenState = .content
    }

    private func rebuildResults() {
        var combined: [WeatherDisplayModel] = []
        if let current = currentLocationModel {
            combined.append(current)
        }
        combined.append(contentsOf: recentResults)
        results = combined
    }
}
