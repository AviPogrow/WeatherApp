//
//  WeatherSearchViewController.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//


import UIKit

final class WeatherSearchViewController: UIViewController {
    
    private let viewModel: WeatherSearchViewModel

    init(viewModel: WeatherSearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        view.backgroundColor = .systemBackground
        title = "Weather"
    }
    
    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }

            switch state {
            case .idle:
                print("Idle")

            case .loading:
                print("Loading weather...")

            case .loaded(let weather):
                print("Loaded weather for \(weather.cityName)")

            case .error(let message):
                print("Error: \(message)")
            }
        }
    }
}
