//
//  AppContainer.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//

import Foundation

final class AppContainer {

    let weatherContainer: WeatherContainer

    init() {
        self.weatherContainer = WeatherContainer()
    }
}
