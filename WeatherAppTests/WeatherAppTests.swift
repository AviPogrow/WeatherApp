//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Avi Pogrow on 6/11/26.
//

import XCTest
import CoreLocation
@testable import WeatherApp

final class WeatherAppTests: XCTestCase {

    @MainActor
    func testSearchWithEmptyCityShowsError() {
        // Given
        let viewModel = WeatherSearchViewModel(
            repository: MockWeatherRepository(),
            localStorage: SpyWeatherLocalStorage(),
            locationService: MockLocationService()
        )

        var capturedState: WeatherSearchViewModel.State?
        viewModel.onStateChanged = { state in
            capturedState = state
        }

        // When
        viewModel.search(city: "   ")

        // Then
        guard case .error(let message) = capturedState else {
            XCTFail("Expected .error state, got \(String(describing: capturedState))")
            return
        }
        XCTAssertEqual(message, "Please enter a city.")
    }
    
    @MainActor
    func testSearchSuccessLoadsWeather() {
        // Given
        let repository = MockWeatherRepository()
        repository.weatherToReturn = .testValue

        let viewModel = WeatherSearchViewModel(
            repository: repository,
            localStorage: SpyWeatherLocalStorage(),
            locationService: MockLocationService()
        )

        let loadedExpectation = expectation(description: "state becomes .loaded")
        var loadedWeather: Weather?

        viewModel.onStateChanged = { state in
            if case .loaded(let weather) = state {
                loadedWeather = weather
                loadedExpectation.fulfill()
            }
        }

        // When
        viewModel.search(city: "Jersey City")

        // Then
        wait(for: [loadedExpectation], timeout: 1.0)
        XCTAssertEqual(loadedWeather?.cityName, "Testville")
    }
    
    @MainActor
    func testSearchFailureShowsErrorMessage() {
        // Given
        let repository = MockWeatherRepository()
        repository.errorToThrow = WeatherError.cityNotFound

        let viewModel = WeatherSearchViewModel(
            repository: repository,
            localStorage: SpyWeatherLocalStorage(),
            locationService: MockLocationService()
        )

        let errorExpectation = expectation(description: "state becomes .error")
        var capturedMessage: String?

        viewModel.onStateChanged = { state in
            if case .error(let message) = state {
                capturedMessage = message
                errorExpectation.fulfill()
            }
        }

        // When
        viewModel.search(city: "Atlantis")

        // Then
        wait(for: [errorExpectation], timeout: 1.0)
        XCTAssertEqual(capturedMessage, "City not found.")
    }
    
    @MainActor
    func testUserSearchPersistsCity() {
        // Given
        let storage = SpyWeatherLocalStorage()

        let viewModel = WeatherSearchViewModel(
            repository: MockWeatherRepository(),
            localStorage: storage,
            locationService: MockLocationService()
        )

        let loadedExpectation = expectation(description: "state becomes .loaded")
        viewModel.onStateChanged = { state in
            if case .loaded = state {
                loadedExpectation.fulfill()
            }
        }

        // When
        viewModel.search(city: "Hoboken")

        // Then
        wait(for: [loadedExpectation], timeout: 1.0)
        XCTAssertEqual(storage.savedCity, "Hoboken")
    }

    @MainActor
    func testAutoLoadDoesNotRePersistCity() {
        // Given
        let storage = SpyWeatherLocalStorage()
        storage.cityToLoad = "Hoboken"

        let viewModel = WeatherSearchViewModel(
            repository: MockWeatherRepository(),
            localStorage: storage,
            locationService: MockLocationService()
        )

        let loadedExpectation = expectation(description: "state becomes .loaded")
        viewModel.onStateChanged = { state in
            if case .loaded = state {
                loadedExpectation.fulfill()
            }
        }

        // When
        viewModel.loadLastSearchedCityIfAvailable()

        // Then
        wait(for: [loadedExpectation], timeout: 1.0)
        XCTAssertNil(storage.savedCity)
    }
    @MainActor
    func testLocationFailureFallsBackToSavedCity() {
        // Given
        let storage = SpyWeatherLocalStorage()
        storage.cityToLoad = "Newark"

        let locationService = MockLocationService()

        let viewModel = WeatherSearchViewModel(
            repository: MockWeatherRepository(),
            localStorage: storage,
            locationService: locationService
        )

        let loadedExpectation = expectation(description: "state becomes .loaded")
        viewModel.onStateChanged = { state in
            if case .loaded = state {
                loadedExpectation.fulfill()
            }
        }

        // When: simulate iOS reporting a location failure
        locationService.onLocationFailed?(CLError(.denied))

        // Then
        wait(for: [loadedExpectation], timeout: 1.0)
    }

    @MainActor
    func testLocationFailureWithNoSavedCityShowsLocationDenied() {
        // Given: empty storage
        let locationService = MockLocationService()

        let viewModel = WeatherSearchViewModel(
            repository: MockWeatherRepository(),
            localStorage: SpyWeatherLocalStorage(),
            locationService: locationService
        )

        var capturedState: WeatherSearchViewModel.State?
        viewModel.onStateChanged = { state in
            capturedState = state
        }

        // When
        locationService.onLocationFailed?(CLError(.denied))

        // Then: synchronous — no fetch happens, state flips directly
        guard case .locationDenied = capturedState else {
            XCTFail("Expected .locationDenied, got \(String(describing: capturedState))")
            return
        }
    }

    @MainActor
    func testLocationSuccessLoadsWeatherForCoordinates() {
        // Given
        let locationService = MockLocationService()

        let viewModel = WeatherSearchViewModel(
            repository: MockWeatherRepository(),
            localStorage: SpyWeatherLocalStorage(),
            locationService: locationService
        )

        let loadedExpectation = expectation(description: "state becomes .loaded")
        viewModel.onStateChanged = { state in
            if case .loaded = state {
                loadedExpectation.fulfill()
            }
        }

        // When: simulate iOS delivering a location
        locationService.onLocationReceived?(
            CLLocation(latitude: 40.72, longitude: -74.04)
        )

        // Then
        wait(for: [loadedExpectation], timeout: 1.0)
    }

}

// MARK: - Test Doubles

final class MockWeatherRepository: WeatherRepository {

    var weatherToReturn: Weather?
    var errorToThrow: Error?

    func fetchWeather(forCity city: String) async throws -> Weather {
        if let errorToThrow { throw errorToThrow }
        return weatherToReturn ?? Weather.testValue
    }

    func fetchWeather(latitude: Double, longitude: Double) async throws -> Weather {
        if let errorToThrow { throw errorToThrow }
        return weatherToReturn ?? Weather.testValue
    }
}

final class SpyWeatherLocalStorage: WeatherLocalStorage {

    var savedCity: String?
    var cityToLoad: String?

    func saveLastSearchedCity(_ city: String) {
        savedCity = city
    }

    func loadLastSearchedCity() -> String? {
        cityToLoad
    }
}

final class MockLocationService: LocationService {

    var onLocationReceived: ((CLLocation) -> Void)?
    var onLocationFailed: ((Error) -> Void)?

    var isPermissionDenied = false

    private(set) var requestCurrentLocationCallCount = 0

    func requestCurrentLocation() {
        requestCurrentLocationCallCount += 1
    }
}

extension Weather {
    static let testValue = Weather(
        cityName: "Testville",
        temperature: 72,
        feelsLike: 74,
        condition: "Clear",
        description: "clear sky",
        humidity: 45,
        windSpeed: 6.2,
        iconCode: "01d"
    )
}

final class WeatherDetailViewModelTests: XCTestCase {

    func testFormattingProperties() {
        let viewModel = WeatherDetailViewModel(weather: .testValue)

        XCTAssertEqual(viewModel.cityName, "Testville")
        XCTAssertEqual(viewModel.temperatureText, "72°")
        XCTAssertEqual(viewModel.feelsLikeText, "Feels like 74°")
        XCTAssertEqual(viewModel.conditionText, "Clear Sky")
        XCTAssertEqual(viewModel.humidityText, "Humidity: 45%")
        XCTAssertEqual(viewModel.windText, "Wind: 6.2 mph")
    }

    func testIconURL() {
        let viewModel = WeatherDetailViewModel(weather: .testValue)

        XCTAssertEqual(
            viewModel.iconURL?.absoluteString,
            "https://openweathermap.org/img/wn/01d@2x.png"
        )
    }
}

final class WeatherResponseDTOTests: XCTestCase {

    func testDecodingOpenWeatherResponse() throws {
        // Trimmed real response from the OpenWeather API
        let json = """
        {
            "name": "Jersey City",
            "main": {
                "temp": 71.6,
                "feels_like": 72.1,
                "humidity": 58
            },
            "weather": [
                {
                    "main": "Clouds",
                    "description": "scattered clouds",
                    "icon": "03d"
                }
            ],
            "wind": {
                "speed": 8.05
            }
        }
        """.data(using: .utf8)!

        // When
        let dto = try JSONDecoder().decode(WeatherResponseDTO.self, from: json)

        // Then
        XCTAssertEqual(dto.name, "Jersey City")
        XCTAssertEqual(dto.main.temp, 71.6)
        XCTAssertEqual(dto.main.feelsLike, 72.1)
        XCTAssertEqual(dto.main.humidity, 58)
        XCTAssertEqual(dto.weather.first?.icon, "03d")
        XCTAssertEqual(dto.wind.speed, 8.05)
    }
}





