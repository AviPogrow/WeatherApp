//
//  WeatherSearchViewController.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//

import UIKit

final class WeatherSearchViewController: UIViewController, UITextFieldDelegate {

    
    private var currentLocationButtonHeightConstraint: NSLayoutConstraint?
    private var searchButtonHeightConstraint: NSLayoutConstraint?
    private let scrollView = UIScrollView()
    private let rootStackView = UIStackView()
    private let inputStackView = UIStackView()
    private let resultsStackView = UIStackView()
    
    private let viewModel: WeatherSearchViewModel
    private let imageLoader: ImageLoader 
    
    
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

    init(
           viewModel: WeatherSearchViewModel,
           imageLoader: ImageLoader
       ) {
           self.viewModel = viewModel
           self.imageLoader = imageLoader
           super.init(nibName: nil, bundle: nil)
           title = "Weather"
       }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        setupUI()
        updateLayout(
            for: view.bounds.size,
            traitCollection: traitCollection
        )
        bindViewModel()
        showIdleState()
        detailsButton.isHidden = true

        // Launch policy: try current location first. If permission is denied
        // or the fix fails, the ViewModel falls back to the last searched
        // city, and shows a prompt to search only if neither is available.
        viewModel.requestCurrentLocationWeather()

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )

        tapGesture.cancelsTouchesInView = false

        view.addGestureRecognizer(tapGesture)
    }
    @objc private func keyboardWillShow(
        notification: Notification
    ) {
        guard
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveRawValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else {
            return
        }

        let options = UIView.AnimationOptions(
            rawValue: curveRawValue << 16
        )

        let keyboardHeight = keyboardFrame.height

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: options
        ) {
            self.scrollView.contentInset.bottom = keyboardHeight
            self.scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight

            self.scrollView.scrollRectToVisible(
                self.searchTextField.convert(
                    self.searchTextField.bounds,
                    to: self.scrollView
                ),
                animated: false
            )
        }
    }
    @objc private func keyboardWillHide(
        notification: Notification
    ) {
        guard
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveRawValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else {
            return
        }

        let options = UIView.AnimationOptions(
            rawValue: curveRawValue << 16
        )

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: options
        ) {
            self.scrollView.contentInset.bottom = 0
            self.scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(
            to: size,
            with: coordinator
        )

        coordinator.animate { [weak self] _ in
            guard let self else { return }

            self.updateLayout(
                for: size,
                traitCollection: self.traitCollection
            )
        }
    }
    
    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateLayout(
            for: view.bounds.size,
            traitCollection: traitCollection
        )
    }
    private func updateLayout(
        for size: CGSize,
        traitCollection: UITraitCollection
    ) {
        let isLandscape = size.width > size.height
        let isRegularWidth =
            traitCollection.horizontalSizeClass == .regular

        let shouldUseTwoColumns =
            isLandscape || isRegularWidth

        //rootStackView.backgroundColor = .yellow
        //inputStackView.backgroundColor = .systemPink
        //resultsStackView.backgroundColor = .systemGreen
        //scrollView.backgroundColor = .blue
        
        rootStackView.axis =
            shouldUseTwoColumns ? .horizontal : .vertical

        rootStackView.distribution =
            shouldUseTwoColumns ? .fillEqually : .fill

        rootStackView.alignment = .fill

        rootStackView.spacing =
            shouldUseTwoColumns ? 32 : 24

        inputStackView.spacing =
            shouldUseTwoColumns ? 8 : 16

        resultsStackView.spacing =
            shouldUseTwoColumns ? 8 : 16

        titleLabel.font = shouldUseTwoColumns
            ? .systemFont(ofSize: 22, weight: .bold)
            : .systemFont(ofSize: 28, weight: .bold)
        
        currentLocationButtonHeightConstraint?.constant =
            shouldUseTwoColumns ? 38 : 48

        searchButtonHeightConstraint?.constant =
            shouldUseTwoColumns ? 36 : 44
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

        // MARK: - Title

        titleLabel.text = "Weather Search"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center

        // MARK: - Search Field

        searchTextField.placeholder = "Enter city"
        searchTextField.borderStyle = .roundedRect
        searchTextField.autocapitalizationType = .words
        searchTextField.returnKeyType = .search

        // MARK: - Search Button

        searchButton.setTitle("Search", for: .normal)
        searchButton.titleLabel?.font = .systemFont(
            ofSize: 18,
            weight: .semibold
        )

        searchButton.layer.cornerRadius = 10
        searchButton.layer.borderWidth = 1
        searchButton.layer.borderColor = UIColor.systemBlue.cgColor

        searchButtonHeightConstraint =
            searchButton.heightAnchor.constraint(equalToConstant: 44)

        searchButtonHeightConstraint?.isActive = true

        searchButton.addTarget(
            self,
            action: #selector(searchButtonTapped),
            for: .touchUpInside
        )

        // MARK: - Current Location Button

        currentLocationButton.setTitle(
            "Use Current Location",
            for: .normal
        )

        currentLocationButton.titleLabel?.font = .systemFont(
            ofSize: 18,
            weight: .semibold
        )

        currentLocationButton.backgroundColor = .systemBlue
        currentLocationButton.tintColor = .white
        currentLocationButton.layer.cornerRadius = 10

        currentLocationButtonHeightConstraint =
            currentLocationButton.heightAnchor.constraint(equalToConstant: 48)

        currentLocationButtonHeightConstraint?.isActive = true

        currentLocationButton.addTarget(
            self,
            action: #selector(currentLocationButtonTapped),
            for: .touchUpInside
        )

        // MARK: - Details Button

        detailsButton.setTitle(
            "View Details",
            for: .normal
        )

        detailsButton.isHidden = true

        detailsButton.addTarget(
            self,
            action: #selector(detailsButtonTapped),
            for: .touchUpInside
        )

        // MARK: - Separator

        separatorLabel.text = "Enter a city to search weather"
        separatorLabel.font = .systemFont(
            ofSize: 14,
            weight: .semibold
        )

        separatorLabel.textColor = .secondaryLabel
        separatorLabel.textAlignment = .center

        // MARK: - Weather Card

        configureWeatherLabels()
        configureWeatherCard()

        let weatherCard = makeWeatherCard()

        // MARK: - Input Stack

        inputStackView.axis = .vertical
        inputStackView.spacing = 16

        inputStackView.addArrangedSubview(titleLabel)
        inputStackView.addArrangedSubview(currentLocationButton)
        inputStackView.addArrangedSubview(separatorLabel)
        inputStackView.addArrangedSubview(searchTextField)
        inputStackView.addArrangedSubview(searchButton)

        // MARK: - Results Stack

        resultsStackView.axis = .vertical
        resultsStackView.spacing = 16

        resultsStackView.addArrangedSubview(weatherCard)
        resultsStackView.addArrangedSubview(detailsButton)

        // MARK: - Root Stack

        rootStackView.axis = .vertical
        rootStackView.spacing = 24
        rootStackView.translatesAutoresizingMaskIntoConstraints = false

        rootStackView.addArrangedSubview(inputStackView)
        rootStackView.addArrangedSubview(resultsStackView)

        view.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        rootStackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(rootStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            rootStackView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor,
                constant: 0
            ),
            rootStackView.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor,
                constant: 24
            ),
            rootStackView.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor,
                constant: -24
            ),
            rootStackView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: -24
            ),
            rootStackView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor,
                constant: -48
            )
        ])
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchButtonTapped()
        return true
    }
    
    @objc private func currentLocationButtonTapped() {
        if viewModel.isLocationPermissionDenied {
            // Permission can't be re-prompted once denied —
            // Settings is the only way for the user to re-enable it.
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        } else {
            viewModel.requestCurrentLocationWeather()
        }
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
                constant: 12
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
            Task {
                do {
                    iconImageView.image = try await imageLoader.image(
                        forIconCode: iconCode
                    )
                } catch {
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

            case .locationDenied:
                self.showLocationDeniedState()
            }        }
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
    
    private func showLocationDeniedState() {
        separatorLabel.text = "Location unavailable. Search for a city below."
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
        
        view.endEditing(true)
        viewModel.search(city: searchTextField.text ?? "")
    }
   
}
