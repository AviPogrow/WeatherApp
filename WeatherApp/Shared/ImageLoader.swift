//
//  ImageLoader.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/12/26.
//

//
//  ImageLoader.swift
//  WeatherApp
//

import UIKit

/// Downloads and caches weather icons in memory. An actor so that
/// concurrent callers can't race the cache, with in-flight task
/// de-duplication: many requests for the same icon share one download.
actor ImageLoader {

    private enum CacheEntry {
        case inProgress(Task<UIImage, Error>)
        case ready(UIImage)
    }

    private var cache: [String: CacheEntry] = [:]

    func image(forIconCode iconCode: String) async throws -> UIImage {

        // Cache hit (or join a download already in flight)
        if let entry = cache[iconCode] {
            switch entry {
            case .ready(let image):
                return image
            case .inProgress(let task):
                return try await task.value
            }
        }

        guard let url = URL(
            string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
        ) else {
            throw URLError(.badURL)
        }

        let task = Task<UIImage, Error> {
            let (data, _) = try await URLSession.shared.data(from: url)

            guard let image = UIImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }

            return image
        }

        // Reserve the slot before suspending, so a reentrant caller
        // joins this download instead of starting a duplicate.
        cache[iconCode] = .inProgress(task)

        do {
            let image = try await task.value
            cache[iconCode] = .ready(image)
            return image
        } catch {
            cache[iconCode] = nil   // failed — allow a retry later
            throw error
        }
    }
}
