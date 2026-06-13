//
//  OpenWeatherRemoteDataSource.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//
import Foundation

final class OpenWeatherRemoteDataSource: RemoteWeatherDataSource {

    func fetchWeather(forCity city: String) async throws -> Weather {
        try await performRequest(queryItems: [
            URLQueryItem(name: "q", value: city)
        ])
    }

    func fetchWeather(latitude: Double, longitude: Double) async throws -> Weather {
        try await performRequest(queryItems: [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude))
        ])
    }

    // MARK: - Shared request pipeline

    private func performRequest(queryItems: [URLQueryItem]) async throws -> Weather {

        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
        components?.queryItems = queryItems + [
            URLQueryItem(name: "units", value: "imperial"),
            URLQueryItem(name: "appid", value: AppConfiguration.openWeatherAPIKey)
        ]

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw WeatherError.invalidAPIKey
        case 404:
            throw WeatherError.cityNotFound
        case 500...599:
            throw WeatherError.serverError
        default:
            throw WeatherError.invalidResponse
        }

        let dto = try JSONDecoder().decode(WeatherResponseDTO.self, from: data)
        return Weather(dto: dto)
    }
}

extension Weather {
    init(dto: WeatherResponseDTO) {
        self.init(
            cityName: dto.name,
            temperature: dto.main.temp,
            feelsLike: dto.main.feelsLike,
            condition: dto.weather.first?.main ?? "",
            description: dto.weather.first?.description ?? "",
            humidity: dto.main.humidity,
            windSpeed: dto.wind.speed,
            iconCode: dto.weather.first?.icon ?? ""
        )
    }
}
