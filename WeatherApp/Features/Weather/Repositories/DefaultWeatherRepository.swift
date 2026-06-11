//
//  DefaultWeatherRepository.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//
import Foundation

final class DefaultWeatherRepository: WeatherRepository {

    private let weatherService: WeatherService

    init(weatherService: WeatherService) {
        self.weatherService = weatherService
    }

    func fetchWeather(
        forCity city: String
    ) async throws -> Weather {

        try await weatherService.fetchWeather(
            forCity: city
        )
    }
}
