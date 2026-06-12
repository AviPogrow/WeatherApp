//
//  WeatherSearchViewController.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//

import UIKit

final class WeatherSearchViewController: UIViewController, UITextFieldDelegate {

    private let viewModel: WeatherSearchViewModel
    var onViewDetailsTapped: ((Weather) -> Void)?
    private var currentWeather: Weather?

    private let titleLabel = UILabel()
    private let searchTextField = UITextField()
    private let searchButton = UIButton(type: .system)
    private let detailsButton = UIButton(type: .system)
    
    private let currentLocationButton = UIButton(type: .system)
    private let separatorLabel = UILabel()

    private let cityLabel = UILabel()
    private let iconImageView = UIImageView()
    private let temperatureLabel = UILabel()
    private let conditionLabel = UILabel()
    private let humidityLabel = UILabel()
    private let windLabel = UILabel()
    
    private let weatherCardView = UIView()

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
        detailsButton.isHidden = true

        viewModel.loadLastSearchedCityIfAvailable()

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )

        tapGesture.cancelsTouchesInView = false

        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func detailsButtonTapped() {
        guard let currentWeather else {
            return
        }

        onViewDetailsTapped?(currentWeather)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func configureWeatherCard() {

        weatherCardView.backgroundColor = .secondarySystemBackground
        weatherCardView.layer.cornerRadius = 16

        weatherCardView.layer.shadowColor = UIColor.black.cgColor
        weatherCardView.layer.shadowOpacity = 0.1
        weatherCardView.layer.shadowRadius = 8
        weatherCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        searchTextField.delegate = self

        titleLabel.text = "Weather Search"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center

        searchTextField.placeholder = "Enter city"
        searchTextField.borderStyle = .roundedRect
        searchTextField.autocapitalizationType = .words
        searchTextField.returnKeyType = .search

        searchButton.setTitle("Search", for: .normal)
        searchButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        searchButton.layer.cornerRadius = 10
        searchButton.layer.borderWidth = 1
        searchButton.layer.borderColor = UIColor.systemBlue.cgColor
        searchButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        searchButton.addTarget(
            self,
            action: #selector(searchButtonTapped),
            for: .touchUpInside
        )
        
        currentLocationButton.setTitle("Use Current Location", for: .normal)
        currentLocationButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        currentLocationButton.backgroundColor = .systemBlue
        currentLocationButton.tintColor = .white
        currentLocationButton.layer.cornerRadius = 10
        currentLocationButton.heightAnchor.constraint(equalToConstant: 48).isActive = true

        currentLocationButton.addTarget(
            self,
            action: #selector(currentLocationButtonTapped),
            for: .touchUpInside
        )
        
        detailsButton.setTitle("View Details", for: .normal)
        detailsButton.isHidden = true

        detailsButton.addTarget(
            self,
            action: #selector(detailsButtonTapped),
            for: .touchUpInside
        )

        separatorLabel.text = "OR"
        separatorLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        separatorLabel.textColor = .secondaryLabel
        separatorLabel.textAlignment = .center

        configureWeatherLabels()
        configureWeatherCard()

        let weatherCard = makeWeatherCard()
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            currentLocationButton,
            separatorLabel,
            searchTextField,
            searchButton,
            weatherCard,
            detailsButton
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchButtonTapped()
        return true
    }
    
    @objc private func currentLocationButtonTapped() {
        viewModel.requestCurrentLocationWeather()
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

    private func makeWeatherCard() -> UIView {

        let contentStack = UIStackView(arrangedSubviews: [
            cityLabel,
            iconImageView,
            temperatureLabel,
            conditionLabel,
            humidityLabel,
            windLabel
        ])

        contentStack.axis = .vertical
        contentStack.spacing = 8
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        weatherCardView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(
                equalTo: weatherCardView.topAnchor,
                constant: 20
            ),

            contentStack.leadingAnchor.constraint(
                equalTo: weatherCardView.leadingAnchor,
                constant: 20
            ),

            contentStack.trailingAnchor.constraint(
                equalTo: weatherCardView.trailingAnchor,
                constant: -20
            ),

            contentStack.bottomAnchor.constraint(
                equalTo: weatherCardView.bottomAnchor,
                constant: -20
            )
        ])

        return weatherCardView
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
        currentWeather = weather

        cityLabel.text = weather.cityName
        temperatureLabel.text = "\(Int(weather.temperature))°"
        conditionLabel.text = weather.description.capitalized

        humidityLabel.text = nil
        windLabel.text = nil

        detailsButton.isHidden = false

        loadWeatherIcon(iconCode: weather.iconCode)
    }
    
    func loadCurrentLocationWeather() {
        viewModel.requestCurrentLocationWeather()
    }
    @objc private func searchButtonTapped() {
        print("SEARCH BUTTON TAPPED")

        view.endEditing(true)
        viewModel.search(city: searchTextField.text ?? "")
    }
   
}
