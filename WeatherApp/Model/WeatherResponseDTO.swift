//
//  WeatherResponseDTO.swift
//  WeatherApp
//
//  Created by Bharath Kumar Kapu on 28/01/26.
//

import Foundation

struct WeatherResponseDTO: Decodable {
    let name: String?
    let main: MainDTO?
    let weather: [WeatherDTO]?
}

struct MainDTO: Decodable {
    let temp: Double?
    let humidity: Int?
}

struct WeatherDTO: Decodable {
    let description: String?
    let icon: String?
}
