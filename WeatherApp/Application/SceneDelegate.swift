//
//  SceneDelegate.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let window = UIWindow(windowScene: windowScene)

        let appContainer = AppContainer()

        let appCoordinator = AppCoordinator(
            window: window,
            appContainer: appContainer
        )

        appCoordinator.start()

        self.window = window
        self.appCoordinator = appCoordinator
    }
}
