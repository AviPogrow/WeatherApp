//
//  OpenWeatherRemoteDataSource.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//
import Foundation

final class OpenWeatherRemoteDataSource: RemoteWeatherDataSource {

    func fetchWeather(
        latitude: Double,
        longitude: Double
    ) async throws -> Weather {

        let urlString = """
        https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=imperial&appid=\(AppConfiguration.openWeatherAPIKey)
        """

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(
            from: url
        )

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

        let dto = try JSONDecoder().decode(
            WeatherResponseDTO.self,
            from: data
        )

        return Weather(
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
    
    func fetchWeather(
        forCity city: String
    ) async throws -> Weather {

        let encodedCity = city.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? city

        let urlString = """
        https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&units=imperial&appid=\(AppConfiguration.openWeatherAPIKey)
        """

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        print("Request URL:", urlString)

        let (data, response) = try await URLSession.shared.data(
            from: url
        )

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
        

        if let rawJSON = String(data: data, encoding: .utf8) {
            print("Raw response:", rawJSON)
        }

        let dto = try JSONDecoder().decode(
            WeatherResponseDTO.self,
            from: data
        )

        return Weather(
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
