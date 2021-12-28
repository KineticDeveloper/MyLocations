//
//  ViewController.swift
//  MyLocations
//
//  Created by Xiao Quan on 12/27/21.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getLocationButton: UIButton!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var lastLocationError: Error?
    var isUpdatingLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }
    
    func updateLabels() {
        // If we have a location, update UI
        if let location = currentLocation {
            messageLabel.text = ""
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            latitudeLabel.text = String(
                format: "%.8f",
                latitude)
            longitudeLabel.text = String(
                format: "%.8f",
                longitude)
            addressLabel.text = ""
            
            tagButton.isEnabled = true
        }
        // If not, check error codes
        else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            
            let statusMessage: String
            /*
             1. Location services restricted from error code
             2. Location services restricted from manager
             3. Currently updating location, waiting for more accurate results
             4. First time using the app. Tap 'Get My Location' to Start".
             */
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain &&
                    error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Updating Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if isUpdatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap \"Get My Location\" to start"
            }
            
            messageLabel.text = statusMessage
        }
        
        getLocationButton.setTitle(
            isUpdatingLocation ? "Stop" : "Get My Location",
            for: .normal)
    }
    
    func startLocationManager() {
        let authStatus = locationManager.authorizationStatus
        print("Authorization Status: ", authStatus.rawValue)
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        if (authStatus == .denied ||
            authStatus == .restricted) {
            requestLocationAuthorization()
            return
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            isUpdatingLocation = true
        }
    }
    
    func stopLocationManager() {
        if isUpdatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            self.isUpdatingLocation = false
        }
    }
    
    @IBAction func getLocation(_ sender: Any) {
        if isUpdatingLocation {
            stopLocationManager()
        } else {
            currentLocation = nil
            lastLocationError = nil
            startLocationManager()
        }
        updateLabels()
    }
    
    func configureGetLocationButton() {
        getLocationButton.setTitle(
            isUpdatingLocation ? "Stop" : "Get My Location",
            for: .normal)
    }
    
    func requestLocationAuthorization() {
        let alert = UIAlertController(
            title: "Permission Denied",
            message: "Please enable location services for this app in user settings",
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil)
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}

extension CurrentLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get current location", error.localizedDescription)
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        
        self.lastLocationError = error
        self.updateLabels()
        self.stopLocationManager()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("Received location from locationManager: \(String(describing: currentLocation))")
        
        // More than 5 seconds ago
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        // Invalid
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        /*
         If it's more accurate than the current location
         and within location manager's desired accuracy, we are done
         */
        print("\n>>>---Accuracy Test---")
        print(newLocation.horizontalAccuracy)
        print(locationManager.desiredAccuracy)
        print("---Accuracy Test--->>>\n")
        if currentLocation == nil ||
            currentLocation!.horizontalAccuracy > newLocation.horizontalAccuracy {
            
            lastLocationError = nil
            currentLocation = newLocation
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                stopLocationManager()
            }
            updateLabels()
        }
    }
}
