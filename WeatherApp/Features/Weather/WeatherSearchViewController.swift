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
    private let resultLabel = UILabel()

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

        resultLabel.text = "Search for a city"
        resultLabel.font = .systemFont(ofSize: 18, weight: .medium)
        resultLabel.textAlignment = .center
        resultLabel.numberOfLines = 0

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            searchTextField,
            searchButton,
            resultLabel
        ])

        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80)
        ])
    }

    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }

            switch state {
            case .idle:
                resultLabel.text = "Search for a city"

            case .loading:
                resultLabel.text = "Loading..."

            case .loaded(let weather):
                resultLabel.text = """
                \(weather.cityName)
                \(weather.temperature)°
                \(weather.description)
                Humidity: \(weather.humidity)%
                Wind: \(weather.windSpeed) mph
                """

            case .error(let message):
                resultLabel.text = message
            }
        }
    }

    @objc private func searchButtonTapped() {
        viewModel.search(city: searchTextField.text ?? "")
    }
}
