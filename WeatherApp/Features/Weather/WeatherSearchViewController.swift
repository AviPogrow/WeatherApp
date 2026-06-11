//
//  WeatherSearchViewController.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//

import UIKit

final class WeatherSearchViewController: UIViewController {

    private let viewModel: WeatherSearchViewModel

    private let titleLabel = UILabel()
    private let searchTextField = UITextField()
    private let searchButton = UIButton(type: .system)

    private let cityLabel = UILabel()
    private let iconImageView = UIImageView()
    private let temperatureLabel = UILabel()
    private let conditionLabel = UILabel()
    private let humidityLabel = UILabel()
    private let windLabel = UILabel()
    
 

    init(viewModel: WeatherSearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Weather"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()
        showIdleState()
        //viewModel.loadLastSearchedCityIfAvailable()
        viewModel.requestCurrentLocationWeather()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        titleLabel.text = "Weather Search"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center

        searchTextField.placeholder = "Enter city"
        searchTextField.borderStyle = .roundedRect
        searchTextField.autocapitalizationType = .words
        searchTextField.returnKeyType = .search

        searchButton.setTitle("Search", for: .normal)
        searchButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        searchButton.addTarget(
            self,
            action: #selector(searchButtonTapped),
            for: .touchUpInside
        )

        configureWeatherLabels()

        let weatherCard = makeWeatherCard()

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            searchTextField,
            searchButton,
            weatherCard
        ])

        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 24
            ),
            stackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -24
            ),
            stackView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 80
            )
        ])
    }

    private func configureWeatherLabels() {
        cityLabel.font = .systemFont(ofSize: 24, weight: .bold)
        cityLabel.textAlignment = .center

        temperatureLabel.font = .systemFont(ofSize: 48, weight: .light)
        temperatureLabel.textAlignment = .center

        conditionLabel.font = .systemFont(ofSize: 18, weight: .medium)
        conditionLabel.textAlignment = .center

        humidityLabel.font = .systemFont(ofSize: 16, weight: .regular)
        humidityLabel.textAlignment = .center

        windLabel.font = .systemFont(ofSize: 16, weight: .regular)
        windLabel.textAlignment = .center
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    private func makeWeatherCard() -> UIStackView {
        let weatherCard = UIStackView(arrangedSubviews: [
            cityLabel,
            iconImageView,
            temperatureLabel,
            conditionLabel,
            humidityLabel,
            windLabel
        ])

        weatherCard.axis = .vertical
        weatherCard.spacing = 8
        weatherCard.alignment = .fill

        return weatherCard
    }
    
    private func loadWeatherIcon(iconCode: String) {
        guard let url = URL(
            string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
        ) else {
            return
        }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                iconImageView.image = UIImage(data: data)
            } catch {
                print("Icon load error:", error)
                iconImageView.image = nil
            }
        }
    }

    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }

            switch state {
            case .idle:
                self.showIdleState()

            case .loading:
                self.showLoadingState()

            case .loaded(let weather):
                self.showWeather(weather)

            case .error(let message):
                self.showError(message)
            }
        }
    }

    private func showIdleState() {
        cityLabel.text = "Search for a city"
        temperatureLabel.text = nil
        conditionLabel.text = nil
        humidityLabel.text = nil
        windLabel.text = nil
        iconImageView.image = nil
    }

    private func showLoadingState() {
        cityLabel.text = "Loading..."
        temperatureLabel.text = nil
        conditionLabel.text = nil
        humidityLabel.text = nil
        windLabel.text = nil
        iconImageView.image = nil
    }
    
    private func showError(_ message: String) {
        cityLabel.text = message
        temperatureLabel.text = nil
        conditionLabel.text = nil
        humidityLabel.text = nil
        windLabel.text = nil
        iconImageView.image = nil
    }

   

    private func showWeather(_ weather: Weather) {
        cityLabel.text = weather.cityName
        temperatureLabel.text = "\(Int(weather.temperature))°"
        conditionLabel.text = weather.description.capitalized
        humidityLabel.text = "Humidity: \(weather.humidity)%"
        windLabel.text = "Wind: \(weather.windSpeed) mph"

        loadWeatherIcon(iconCode: weather.iconCode)
    }

    @objc private func searchButtonTapped() {
        viewModel.search(city: searchTextField.text ?? "")
    }
}
