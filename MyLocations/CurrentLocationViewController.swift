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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }
    
    func updateLabels() {
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
        } else {
            messageLabel.text = "Press \"Get My Location\" to update location"
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
        }
    }
    
    @IBAction func getLocation(_ sender: Any) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        let authStatus = locationManager.authorizationStatus
        print("Authorization Status: ", authStatus)
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        if (authStatus == .denied ||
            authStatus == .restricted) {
            requestLocationAuthorization()
            return
        }
        
        locationManager.startUpdatingLocation()
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
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!
        updateLabels()
    }
}
