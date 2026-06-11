//
//  WeatherMenuView.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//

import SwiftUI

struct WeatherMenuView: View {

    let onUseCurrentLocation: () -> Void
    let onSearchByCity: () -> Void

    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            Text("Weather App")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Choose how you want to check the weather.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 16) {
                Button(action: onUseCurrentLocation) {
                    Text("Use Current Location")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(action: onSearchByCity) {
                    Text("Search by City")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .navigationTitle("Weather")
    }
}
