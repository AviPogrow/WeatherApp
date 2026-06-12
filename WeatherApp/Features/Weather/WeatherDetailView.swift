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
    let imageLoader: ImageLoader
    
    

    var body: some View {
        GeometryReader { proxy in
            let isLandscape = proxy.size.width > proxy.size.height

            let shouldUseTwoColumns =
                isLandscape &&
                proxy.size.width > 600

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
        ScrollView {
            VStack(spacing: 24) {
                fullSummarySection

                detailsCard

                moreInfoCard
            }
            .padding()
        }
    }

    private var landscapeLayout: some View {
        HStack(spacing: 32) {
            compactSummarySection
                .frame(maxWidth: .infinity)

            VStack(spacing: 16) {
                detailsCard

                moreInfoCard

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 48)
        .padding(.vertical, 12)
    }

    private var fullSummarySection: some View {
        VStack(spacing: 12) {
            Text(viewModel.cityName)
                .font(.largeTitle)
                .fontWeight(.bold)

            weatherIcon(size: 120)

            Text(viewModel.temperatureText)
                .font(.system(size: 64, weight: .light))

            Text(viewModel.conditionText)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var compactSummarySection: some View {
        VStack(spacing: 8) {
            Text(viewModel.cityName)
                .font(.title)
                .fontWeight(.bold)

            weatherIcon(size: 72)

            Text(viewModel.temperatureText)
                .font(.system(size: 56, weight: .light))

            Text(viewModel.conditionText)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    @State private var iconImage: UIImage?

        @ViewBuilder
        private func weatherIcon(size: CGFloat) -> some View {
            Group {
                if let iconImage {
                    Image(uiImage: iconImage)
                        .resizable()
                        .scaledToFit()
                } else {
                    ProgressView()
                }
            }
            .frame(width: size, height: size)
            .task {
                iconImage = try? await imageLoader.image(
                    forIconCode: viewModel.iconCode
                )
                
            }
        }

    private var detailsCard: some View {
        VStack(spacing: 14) {
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
        VStack(alignment: .leading, spacing: 14) {
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
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
    }
}
