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

        let viewController =
            weatherContainer.makeWeatherSearchViewController()

        viewController.onViewDetailsTapped = { [weak self] weather in
            self?.showWeatherDetails(weather)
        }

        navigationController.setViewControllers(
            [viewController],
            animated: false
        )
    }
    
    private func showWeatherDetails(
        _ weather: Weather
    ) {

        let detailView =
            weatherContainer.makeWeatherDetailView(
                weather: weather
            )

        let detailViewController =
            UIHostingController(
                rootView: detailView
            )

        navigationController.pushViewController(
            detailViewController,
            animated: true
        )
    }
}
