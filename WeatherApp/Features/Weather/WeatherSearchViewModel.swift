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
        case locationDenied
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
    
    var isLocationPermissionDenied: Bool {
        locationService.isPermissionDenied
    }
    
    
    // Workaround for swiftlang/swift#87316: under MainActor default
    // isolation, the synthesized isolated deinit over-releases when the
    // object is deallocated off the main thread (which XCTest does).
    // An explicit deinit avoids the broken codegen path.
    nonisolated deinit {}
    
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

        locationService.onLocationFailed = { [weak self] error in
            guard let self else { return }

            if !self.loadLastSearchedCityIfAvailable() {
                self.state = .locationDenied
            }
        }
    }
    
   
    /// Loads weather for the last searched city, if one is saved.
    /// Returns false when no usable city is stored, so the caller
    /// can decide what to show instead.
    @discardableResult
    func loadLastSearchedCityIfAvailable() -> Bool {
        guard
            let city = localStorage.loadLastSearchedCity()?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            !city.isEmpty
        else {
            return false
        }

        fetchWeatherForCity(
            city,
            shouldPersist: false
        )

        return true
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
