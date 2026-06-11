//
//  WeatherContainer.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//
import UIKit

final class WeatherContainer {

    func makeWeatherSearchViewController() -> WeatherSearchViewController {

        
        let remoteDataSource = OpenWeatherRemoteDataSource()

        let repository = DefaultWeatherRepository(
            remoteDataSource: remoteDataSource
        )

        let viewModel = WeatherSearchViewModel(
            repository: repository
        )

        return WeatherSearchViewController(
            viewModel: viewModel
        )
    }
}
