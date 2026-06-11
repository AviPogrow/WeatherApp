//
//  WeatherResponseDTO.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//

import Foundation

struct WeatherResponseDTO: Decodable {
    let name: String
    let main: MainDTO
    let weather: [WeatherDTO]
    let wind: WindDTO
}

struct MainDTO: Decodable {
    let temp: Double
    let feelsLike: Double
    let humidity: Int

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case humidity
    }
}

struct WeatherDTO: Decodable {
    let main: String
    let description: String
    let icon: String
}

struct WindDTO: Decodable {
    let speed: Double
}
