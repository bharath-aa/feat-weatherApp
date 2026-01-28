//
//  Weather.swift
//  WeatherApp
//
//  Created by Bharath Kumar Kapu on 28/01/26.
//

import Foundation

struct Weather: Decodable {
    let cityName: String
    let temperature: Double
    let description: String
    let icon: String
}

extension Weather {
    init(dto: WeatherResponseDTO) throws {
        guard
            let city = dto.name,
            let temp = dto.main?.temp,
            let weatherInfo = dto.weather?.first,
            let description = weatherInfo.description,
            let icon = weatherInfo.icon
        else {
            throw WeatherMappingError.missingRequiredFields
        }

        self.cityName = city
        self.temperature = temp
        self.description = description.capitalized
        self.icon = icon
    }
}

enum WeatherMappingError: LocalizedError {
    case missingRequiredFields

    var errorDescription: String? {
        "Weather data is incomplete."
    }
}
