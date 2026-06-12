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
        let locationService = CoreLocationService()

        let repository = DefaultWeatherRepository(
            remoteDataSource: remoteDataSource
        )

        let viewModel = WeatherSearchViewModel(
            repository: repository,
            localStorage: localStorage,
            locationService: locationService
        )

        return WeatherSearchViewController(
            viewModel: viewModel
        )
    }
    
    func makeWeatherDetailView(
        weather: Weather
    ) -> WeatherDetailView {

        let viewModel = WeatherDetailViewModel(
            weather: weather
        )

        return WeatherDetailView(
            viewModel: viewModel
        )
    }
}
