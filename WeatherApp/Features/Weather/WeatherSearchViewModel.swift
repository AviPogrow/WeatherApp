//
//  WeatherSearchViewModel.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//

import Foundation
import CoreLocation

@MainActor
final class WeatherSearchViewModel {

    enum State {
        case idle
        case loading
        case loaded(Weather)
        case error(String)
    }
    
    
    private let localStorage: WeatherLocalStorage
    private let repository: WeatherRepository
    private let locationService: LocationService
    

    private(set) var state: State = .idle {
        didSet {
            onStateChanged?(state)
        }
    }

    var onStateChanged: ((State) -> Void)?
    
    init(
        repository: WeatherRepository,
        localStorage: WeatherLocalStorage,
        locationService: LocationService
    ) {
        self.repository = repository
        self.localStorage = localStorage
        self.locationService = locationService

        setupLocationHandling()
    }
    
    func requestCurrentLocationWeather() {
        locationService.requestLocationPermission()
        locationService.requestCurrentLocation()
    }

    private func fetchWeatherForCurrentLocation(
        latitude: Double,
        longitude: Double
    ) async {
        state = .loading

        do {
            let weather = try await repository.fetchWeather(
                latitude: latitude,
                longitude: longitude
            )

            state = .loaded(weather)
        } catch let error as LocalizedError {
            state = .error(
                error.errorDescription ?? "Unable to load current location weather."
            )
        } catch {
            state = .error("Unable to load current location weather.")
        }
    }
    
    private func setupLocationHandling() {
        locationService.onLocationReceived = { [weak self] location in
            guard let self else { return }

            Task {
                await self.fetchWeatherForCurrentLocation(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
        }
    }
    
    
    func loadLastSearchedCityIfAvailable() {
        guard let city = localStorage.loadLastSearchedCity(),
              !city.isEmpty else {
            return
        }

        fetchWeatherForCity(
            city,
            shouldPersist: false
        )
    }
    func search(city: String) {
        fetchWeatherForCity(
            city,
            shouldPersist: true
        )
    }
    private func fetchWeatherForCity(
        _ city: String,
        shouldPersist: Bool
    ) {
        let trimmedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedCity.isEmpty else {
            state = .error("Please enter a city.")
            return
        }

        state = .loading

        Task {
            do {
                let weather = try await repository.fetchWeather(
                    forCity: trimmedCity
                )

                if shouldPersist {
                    localStorage.saveLastSearchedCity(trimmedCity)
                }

                state = .loaded(weather)

            } catch let error as LocalizedError {
                state = .error(error.errorDescription ?? "Unknown error")

            } catch {
                state = .error("Unexpected error")
            }
        }
    }
}
