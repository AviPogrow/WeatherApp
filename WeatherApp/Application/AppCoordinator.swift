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

    init(
        window: UIWindow,
        appContainer: AppContainer
    ) {
        self.window = window
        self.appContainer = appContainer
    }

    func start() {
        let rootViewController =
            appContainer.weatherContainer
                .makeWeatherSearchViewController()

        let navigationController = UINavigationController(
            rootViewController: rootViewController
        )

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
