//
//  UserDefaultsWeatherLocalStorage.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//
import Foundation

final class UserDefaultsWeatherLocalStorage: WeatherLocalStorage {

    private enum Keys {
        static let lastSearchedCity = "lastSearchedCity"
    }

    func saveLastSearchedCity(_ city: String) {
        UserDefaults.standard.set(
            city,
            forKey: Keys.lastSearchedCity
        )
    }

    func loadLastSearchedCity() -> String? {
        UserDefaults.standard.string(
            forKey: Keys.lastSearchedCity
        )
    }
}
