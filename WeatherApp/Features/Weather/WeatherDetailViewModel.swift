//
//  WeatherDetailViewModel.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/12/26.
//

import Foundation

struct WeatherDetailViewModel {

    private let weather: Weather

    init(weather: Weather) {
        self.weather = weather
    }

    var cityName: String {
        weather.cityName
    }

    var temperatureText: String {
        "\(Int(weather.temperature))°"
    }

    var feelsLikeText: String {
        "Feels like \(Int(weather.feelsLike))°"
    }

    var conditionText: String {
        weather.description.capitalized
    }

    var humidityText: String {
        "Humidity: \(weather.humidity)%"
    }

    var windText: String {
        "Wind: \(weather.windSpeed) mph"
    }

    var iconURL: URL? {
        URL(
            string: "https://openweathermap.org/img/wn/\(weather.iconCode)@2x.png"
        )
    }
}
