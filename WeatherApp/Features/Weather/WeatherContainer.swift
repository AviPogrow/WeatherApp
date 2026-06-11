//
//  WeatherContainer.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//
import UIKit

final class WeatherContainer {

    func makeWeatherSearchViewController() -> WeatherSearchViewController {

        let localStorage = UserDefaultsWeatherLocalStorage()
        let remoteDataSource = OpenWeatherRemoteDataSource()

        let repository = DefaultWeatherRepository(
            remoteDataSource: remoteDataSource
        )

        let viewModel = WeatherSearchViewModel(
            repository: repository,
            localStorage: localStorage
        )

        return WeatherSearchViewController(
            viewModel: viewModel
        )
    }
}
