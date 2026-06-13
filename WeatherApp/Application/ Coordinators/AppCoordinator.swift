//
//  AppCoordinator.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//

import UIKit

final class AppCoordinator {

    private let window: UIWindow
    private let appContainer: AppContainer

    private var weatherCoordinator: WeatherCoordinator?

    init(
        window: UIWindow,
        appContainer: AppContainer
    ) {
        self.window = window
        self.appContainer = appContainer
    }

    func start() {
        let navigationController = UINavigationController()

        let weatherCoordinator = WeatherCoordinator(
            navigationController: navigationController,
            weatherContainer: appContainer.weatherContainer
        )

        self.weatherCoordinator = weatherCoordinator

        weatherCoordinator.start()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
