//
//  CoreLocationService.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//

import CoreLocation

final class CoreLocationService: NSObject {

    private let locationManager = CLLocationManager()

    var onLocationReceived: ((CLLocation) -> Void)?

    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
   
}

extension CoreLocationService: LocationService {

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestCurrentLocation() {
        locationManager.requestLocation()
    }
}

extension CoreLocationService: CLLocationManagerDelegate {
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.first else {
            return
        }

        print("Location received:", location)

        onLocationReceived?(location)
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Location Error:", error)
    }

    
}
