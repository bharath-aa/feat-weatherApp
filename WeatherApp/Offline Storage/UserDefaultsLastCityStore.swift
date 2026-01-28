//
//  UserDefaultsLastCityStore.swift
//  WeatherApp
//
//  Created by Bharath Kumar Kapu on 28/01/26.
//

import Foundation

protocol LastCityStoreProtocol {
    func save(_ city: String)
    func load() -> String?
    func clear()
}

final class UserDefaultsLastCityStore: LastCityStoreProtocol {

    private let key = "last_searched_city"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(_ city: String) {
        defaults.set(city, forKey: key)
    }

    func load() -> String? {
        defaults.string(forKey: key)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
