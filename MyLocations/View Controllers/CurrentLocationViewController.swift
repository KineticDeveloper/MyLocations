//
//  ViewController.swift
//  MyLocations
//
//  Created by Xiao Quan on 12/27/21.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getLocationButton: UIButton!
    
    var managedObjectContext: NSManagedObjectContext!
    
    // GPS Coordinates
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var lastLocationError: Error?
    var isUpdatingLocation = false
    
    // Reverse Geocoding
    let geoCoder = CLGeocoder()
    var lastPlacemark: CLPlacemark?
    var lastGeocodingError: Error?
    var isReverseGeocoding = false
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            controller.coordinates = CLLocationCoordinate2D(
                latitude: currentLocation!.coordinate.latitude,
                longitude: currentLocation!.coordinate.longitude)
            controller.date = Date()
            controller.address = "No Address Found"
            if let placemark = lastPlacemark {
                controller.address = getAddressFromPlacemark(from: placemark)
            }
        }
    }
    
    func updateLabels() {
        // If we have a location, update UI
        if let location = currentLocation {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            latitudeLabel.text = String(
                format: "%.8f",
                latitude)
            longitudeLabel.text = String(
                format: "%.8f",
                longitude)
            addressLabel.text = ""
            
            tagButton.isHidden = false
            
            let addressResult: String
            if let placemark = lastPlacemark {
                addressResult = getAddressFromPlacemark(from: placemark)
            } else if isReverseGeocoding {
                addressResult = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressResult = "Error Finding Address"
            } else {
                addressResult = "No Address Found"
            }
            
            addressLabel.text = addressResult
            messageLabel.text = isUpdatingLocation ? "Updating..." : ""
        }
        // If not, check error codes
        else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            
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
        
        configureGetLocationButton()
    }
    
    func getAddressFromPlacemark(from placemark: CLPlacemark) -> String {
        var lineOne = ""
        if let temp = placemark.subThoroughfare {
            lineOne += temp + " "
        }
        if let temp = placemark.thoroughfare {
            lineOne += temp
        }

        var lineTwo = ""
        if let temp = placemark.locality {
            lineTwo += temp + ", "
        }
        if let temp = placemark.administrativeArea {
            lineTwo += temp + ", "
        }
        if let temp = placemark.postalCode {
            lineTwo += temp
        }
        
        var lineThree = ""
        if let temp = placemark.country {
            lineThree += temp
        }
        return lineOne + "\n" + lineTwo + "\n" + lineThree
    }
    
    @IBAction func getLocation(_ sender: Any) {
        if isUpdatingLocation {
            print("User Pressed Stop")
            stopLocationManager()
            updateLabels()
        } else {
            currentLocation = nil
            lastLocationError = nil
            lastPlacemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
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
            timer = Timer.scheduledTimer(
                timeInterval: 60,
                target: self,
                selector: #selector(timeout),
                userInfo: nil,
                repeats: false)
        }
    }
    
    func stopLocationManager() {
        if isUpdatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            isUpdatingLocation = false
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    @objc func timeout() {
        print("***TIMEOUT***")
        if currentLocation == nil {
            stopLocationManager()
            lastLocationError = NSError(
                domain: "MyLocationsTimeout",
                code: 1,
                userInfo: nil)
            updateLabels()
        }
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
        self.stopLocationManager()
        self.updateLabels()
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
        
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = currentLocation {
            distance = newLocation.distance(from: location)
        }
        /*
         If it's
             1. more accurate than the current location, or
             2. within location manager's desired accuracy, or
             3. not changing in distance from previous location
         we are done.
         */
        // 1.
        if currentLocation == nil ||
            currentLocation!.horizontalAccuracy > newLocation.horizontalAccuracy {
            
            lastLocationError = nil
            currentLocation = newLocation
            
            // 2.
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("Stopped because accuracy reached!")
                stopLocationManager()
            }
            updateLabels()
            
            // Use this to override previous geocoding, if it's taking place,
            // so we always get the address for the latest coordinate.
            if distance > 0 {
                isReverseGeocoding = false
            }
            
            if !isReverseGeocoding {
                isReverseGeocoding = true
                geoCoder.reverseGeocodeLocation(newLocation) { placemarks, error in
                    
                    self.lastGeocodingError = error
                    
                    if error == nil, let places = placemarks, !places.isEmpty {
                        self.lastPlacemark = places.last
                    } else {
                        self.lastPlacemark = nil
                    }
                    
                    self.isReverseGeocoding = false
                    self.updateLabels()
                }
            }
        }
        // 3.
        else if distance < 10 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(currentLocation!.timestamp)
            if timeInterval > 10 {
                print("Stopped updating location: Location not changing for over 10s")
                stopLocationManager()
                updateLabels()
            }
        }
        print("Distance from prev location: \(distance)")
    }
}
