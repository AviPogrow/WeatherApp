//
//  WeatherCoordinator.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//
import UIKit

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
        let viewController =
            weatherContainer.makeWeatherSearchViewController()

        navigationController.setViewControllers(
            [viewController],
            animated: false
        )
    }
}
