//
//  WeatherCoordinator.swift
//  WeatherApp
//
//  Created by Bharath Kumar Kapu on 28/01/26.
//

import UIKit
import SwiftUI

protocol Coordinator {
    func start()
}

final class WeatherCoordinator: Coordinator {

    private let navigationController: UINavigationController
    private let weatherService: WeatherServiceProtocol
    private let locationService: LocationServiceProtocol

    init(
        navigationController: UINavigationController,
        weatherService: WeatherServiceProtocol,
        locationService: LocationServiceProtocol
    ) {
        self.navigationController = navigationController
        self.weatherService = weatherService
        self.locationService = locationService
    }

    func start() {
        let viewModel = WeatherViewModel(
            weatherService: weatherService,
            locationService: locationService
        )

        let view = WeatherView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        navigationController.setViewControllers([hostingController], animated: false)
    }
}
