//
//  WeatherLocalStorage.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//

import Foundation

protocol WeatherLocalStorage {
    func saveLastSearchedCity(_ city: String)
    func loadLastSearchedCity() -> String?
}
