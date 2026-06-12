//
//  UserDefaultsWeatherLocalStorage.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//
import Foundation
import Foundation

final class UserDefaultsWeatherLocalStorage: WeatherLocalStorage {

    private enum Keys {
        static let lastSearchedCity = "lastSearchedCity"
    }

    func saveLastSearchedCity(_ city: String) {
        print("Saving last searched city:", city)

        UserDefaults.standard.set(
            city,
            forKey: Keys.lastSearchedCity
        )
    }

    func loadLastSearchedCity() -> String? {
        let city = UserDefaults.standard.string(
            forKey: Keys.lastSearchedCity
        )

        print("Loaded last searched city:", city ?? "nil")

        return city
    }
}
