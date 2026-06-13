//
//  DefaultWeatherRepository.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//
import Foundation

final class DefaultWeatherRepository: WeatherRepository {

    private let remoteDataSource: RemoteWeatherDataSource

    init(remoteDataSource: RemoteWeatherDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchWeather(
        forCity city: String
    ) async throws -> Weather {

        try await remoteDataSource.fetchWeather(
            forCity: city
        )
    }
    
    func fetchWeather(
        latitude: Double,
        longitude: Double
    ) async throws -> Weather {

        try await remoteDataSource.fetchWeather(
            latitude: latitude,
            longitude: longitude
        )
    }
}
