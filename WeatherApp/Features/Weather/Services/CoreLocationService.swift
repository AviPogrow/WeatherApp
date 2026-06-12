//
//  CoreLocationService.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//
import CoreLocation

final class CoreLocationService: NSObject {

    private let locationManager = CLLocationManager()

    /// Set when a caller has requested a location but we're waiting on
    /// the user to respond to the permission prompt. Without this gate,
    /// locationManagerDidChangeAuthorization (which also fires at manager
    /// creation) would trigger duplicate location fetches.
    private var isAwaitingAuthorization = false

    var onLocationReceived: ((CLLocation) -> Void)?
    var onLocationFailed: ((Error) -> Void)?

    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    var isPermissionDenied: Bool {
        switch locationManager.authorizationStatus {
        case .denied, .restricted:
            return true
        default:
            return false
        }
    }
}

extension CoreLocationService: LocationService {

    func requestCurrentLocation() {
        switch locationManager.authorizationStatus {

        case .notDetermined:
            isAwaitingAuthorization = true
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()

        case .denied, .restricted:
            onLocationFailed?(CLError(.denied))

        @unknown default:
            onLocationFailed?(CLError(.locationUnknown))
        }
    }
}

extension CoreLocationService: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        // Only react if we triggered the permission prompt ourselves.
        // This callback also fires at CLLocationManager creation, and
        // acting on that would duplicate the explicit request path.
        guard isAwaitingAuthorization else { return }

        switch manager.authorizationStatus {

        case .authorizedWhenInUse, .authorizedAlways:
            isAwaitingAuthorization = false
            manager.requestLocation()

        case .denied, .restricted:
            isAwaitingAuthorization = false
            onLocationFailed?(CLError(.denied))

        case .notDetermined:
            break

        @unknown default:
            isAwaitingAuthorization = false
            onLocationFailed?(CLError(.locationUnknown))
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.first else {
            onLocationFailed?(CLError(.locationUnknown))
            return
        }

        onLocationReceived?(location)
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        onLocationFailed?(error)
    }
}
