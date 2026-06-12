//
//  WeatherDetailView.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/12/26.
//

import SwiftUI

struct WeatherDetailView: View {

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @Environment(\.verticalSizeClass)
    private var verticalSizeClass
    
    let viewModel: WeatherDetailViewModel

    var body: some View {
        GeometryReader { proxy in
            let shouldUseTwoColumns =
                horizontalSizeClass == .regular &&
                proxy.size.width > proxy.size.height &&
                proxy.size.width > 700

            Group {
                if shouldUseTwoColumns {
                    landscapeLayout
                } else {
                    portraitLayout
                }
            }
            .frame(
                width: proxy.size.width,
                height: proxy.size.height
            )
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var portraitLayout: some View {
        VStack(spacing: 24) {

            summarySection

            detailsCard

            moreInfoCard

            Spacer()
        }
        .padding()
    }

    private var landscapeLayout: some View {
        HStack(spacing: 32) {

            summarySection
                .frame(maxWidth: .infinity)

            VStack(spacing: 20) {

                detailsCard

                moreInfoCard

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 48)
        .padding(.vertical, 24)
    }

    private var summarySection: some View {
        VStack(spacing: 12) {

            Text(viewModel.cityName)
                .font(.largeTitle)
                .fontWeight(.bold)

            if let iconURL = viewModel.iconURL {

                AsyncImage(url: iconURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 120, height: 120)
            }

            Text(viewModel.temperatureText)
                .font(.system(size: 64, weight: .light))

            Text(viewModel.conditionText)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var detailsCard: some View {
        VStack(spacing: 16) {

            detailRow(
                systemImage: "thermometer.medium",
                title: "Feels Like",
                value: viewModel.feelsLikeText
            )

            Divider()

            detailRow(
                systemImage: "drop",
                title: "Humidity",
                value: viewModel.humidityText
            )

            Divider()

            detailRow(
                systemImage: "wind",
                title: "Wind",
                value: viewModel.windText
            )
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(16)
    }

    private var moreInfoCard: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            Text("More Information")
                .font(.headline)

            Divider()

            detailRow(
                systemImage: "doc.text",
                title: "Description",
                value: viewModel.conditionText
            )
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(16)
    }

    private func detailRow(
        systemImage: String,
        title: String,
        value: String
    ) -> some View {

        HStack(spacing: 12) {

            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32)

            Text(title)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
        }
    }
}
