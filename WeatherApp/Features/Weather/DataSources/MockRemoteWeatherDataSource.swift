//
//  MockRemoteWeatherDataSource.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//

import Foundation

final class MockRemoteWeatherDataSource: RemoteWeatherDataSource {

    func fetchWeather(
        forCity city: String
    ) async throws -> Weather {

        Weather(
            cityName: city,
            temperature: 72,
            feelsLike: 74,
            condition: "Clear",
            description: "clear sky",
            humidity: 45,
            windSpeed: 6.2,
            iconCode: "01d"
        )
    }
}
