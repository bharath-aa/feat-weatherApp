//
//  Untitled.swift
//  WeatherApp
//
//  Created by Bharath Kumar Kapu on 28/01/26.
//

import Foundation

struct WeatherDisplayModel: Identifiable {
    let city: String
    let temperature: String
    let description: String
    let iconURL: URL?

    var id: UUID { UUID() }
    
    init(from weather: Weather) {
        city = weather.cityName
        temperature = "\(Int(weather.temperature))°C"
        description = weather.description
        iconURL = URL(
            string: "https://openweathermap.org/img/wn/\(weather.icon)@2x.png"
        )
    }
}
