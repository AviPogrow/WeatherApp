//
//  Errors.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//

import Foundation

enum WeatherError: LocalizedError {
    case cityNotFound
    case invalidAPIKey
    case serverError
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .cityNotFound:
            return "City not found."

        case .invalidAPIKey:
            return "Invalid API key."

        case .serverError:
            return "Server error. Please try again."

        case .invalidResponse:
            return "Unable to process weather data."
        }
    }
}
