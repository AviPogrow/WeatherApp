//
//  WeatherSearchViewModel.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//

import Foundation

@MainActor
final class WeatherSearchViewModel {

    enum State {
        case idle
        case loading
        case loaded(Weather)
        case error(String)
    }
    private let repository: WeatherRepository

    private(set) var state: State = .idle {
        didSet {
            onStateChanged?(state)
        }
    }

    var onStateChanged: ((State) -> Void)?
    
    init(repository: WeatherRepository) {
        self.repository = repository
    }
    
    func search(city: String) {
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
                state = .loaded(weather)
           
            } catch let error as LocalizedError {

                print("Weather fetch error:", error)

                state = .error(
                    error.errorDescription ??
                    "Unknown error"
                )

            } catch {

                print("Weather fetch error:", error)

                state = .error(
                    "Unexpected error"
                )
            }
        }
    }
}
