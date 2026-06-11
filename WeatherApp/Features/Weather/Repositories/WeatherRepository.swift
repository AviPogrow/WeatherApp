//
//  WeatherRepository.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//

import Foundation

protocol WeatherRepository {
    func fetchWeather(
        forCity city: String
    ) async throws -> Weather
}
