//
//  LocationService.swift
//  WeatherApp
//
//  Created by Avi Pogrow on 6/11/26.
//

import CoreLocation

protocol LocationService: AnyObject {

    var onLocationReceived: ((CLLocation) -> Void)? { get set }
    var onLocationFailed: ((Error) -> Void)? { get set }
    var isPermissionDenied: Bool { get }

    func requestCurrentLocation()
}
