//
//  WeatherCoordinator.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//

import UIKit
import SwiftUI

final class WeatherCoordinator {

    private let navigationController: UINavigationController
    private let weatherContainer: WeatherContainer

    init(
        navigationController: UINavigationController,
        weatherContainer: WeatherContainer
    ) {
        self.navigationController = navigationController
        self.weatherContainer = weatherContainer
    }

    func start() {
        let menuView = WeatherMenuView(
            onUseCurrentLocation: { [weak self] in
                self?.showWeatherSearch(loadCurrentLocation: true)
            },
            onSearchByCity: { [weak self] in
                self?.showWeatherSearch(loadCurrentLocation: false)
            }
        )

        let menuViewController = UIHostingController(
            rootView: menuView
        )

        navigationController.setViewControllers(
            [menuViewController],
            animated: false
        )
    }

    private func showWeatherSearch(loadCurrentLocation: Bool) {
        let viewController =
            weatherContainer.makeWeatherSearchViewController()

        navigationController.pushViewController(
            viewController,
            animated: true
        )

        if loadCurrentLocation {
            viewController.loadCurrentLocationWeather()
        }
    }
}
