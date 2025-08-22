//
//  LocationManager.swift
//  TennisStarter
//
//  Created by Mabook on 29/2/25.
//  Copyright © 2025 University of Chester. All rights reserved.
//


import Foundation
import CoreLocation

/* - LocationManager handles retrieving and managing location information
   - It uses CoreLocation to determine the device's current location */
class LocationManager: NSObject, CLLocationManagerDelegate {
    
    // Singleton instance for easy access throughout the app
    static let shared = LocationManager()
    
    // Core Location manager
    private let locationManager = CLLocationManager()
    
    // Current location information
    private var currentLocation: CLLocation?
    private var currentCity: String = "Unknown"
    private var currentCountry: String = "Unknown"
    
    // Completion handler for location updates
    private var locationUpdateCompletion: ((Bool) -> Void)?
    
    // Private initializer for singleton pattern
    private override init() {
        super.init()
        setupLocationManager()
    }
    
    // Set up the location manager and request permissions
     
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Start requesting location updates
     
    func startLocationUpdates(completion: @escaping (Bool) -> Void) {
        locationUpdateCompletion = completion
        locationManager.startUpdatingLocation()
    }
    
    // Stop location updates to conserve battery
     
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    /* -  Get the current city and country
       - Returns a tuple with (city, country) strings */
    func getCurrentLocation() -> (city: String, country: String) {
        return (currentCity, currentCountry)
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last
        else { return }
        
        // Only update if location is recent
        let howRecent = location.timestamp.timeIntervalSinceNow
        guard abs(howRecent) < 15.0
        else { return }
        
        currentLocation = location
        
        // Reverse geocode the location to get city and country
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self,
                  let placemark = placemarks?.first,
                  error == nil else {
                self?.locationUpdateCompletion?(false)
                return
            }
            
            self.currentCity = placemark.locality ?? "Unknown"
            self.currentCountry = placemark.country ?? "Unknown"
            
            // Notify completion
            self.locationUpdateCompletion?(true)
            
            // Stop updating location to save battery
            self.stopLocationUpdates()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with error: \(error.localizedDescription)")
        locationUpdateCompletion?(false)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            locationUpdateCompletion?(false)
        }
    }
}
