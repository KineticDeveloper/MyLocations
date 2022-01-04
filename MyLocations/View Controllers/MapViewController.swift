//
//  MapViewController.swift
//  MyLocations
//
//  Created by Xiao Quan on 1/2/22.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var locations = [Location]()
    var managedObjectContext: NSManagedObjectContext! {
        didSet {
            NotificationCenter.default.addObserver(
                forName: .NSManagedObjectContextObjectsDidChange,
                object: managedObjectContext,
                queue: OperationQueue.main) { _ in
                    if self.isViewLoaded {
                        self.updateLocations()
                    }
                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem?.image = UIImage(systemName: "location.circle.fill")
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: "mappin.circle.fill")
        updateLocations()
        if !locations.isEmpty {
            showTaggedLocation()
        }
        
        mapView.delegate = self
    }
    
    func updateLocations() {
        mapView.removeAnnotations(locations)
        
        let fetchRequest: NSFetchRequest<Location> = NSFetchRequest(entityName: "Location")
        locations = try! managedObjectContext.fetch(fetchRequest)
        
        mapView.addAnnotations(locations)
    }
    
    @IBAction func showUserLocation() {
        let userCoordinate = mapView.userLocation.coordinate
        
        let region = MKCoordinateRegion(
            center: userCoordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000)
        
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    @IBAction func showTaggedLocation() {
        let region = region(for: locations)
        
        mapView.setRegion(region, animated: true)
    }
    
    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion
        switch annotations.count {
        case 0:
            region = MKCoordinateRegion(
                center: mapView.userLocation.coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000)
        case 1:
            let annotation = annotations[0]
            region = MKCoordinateRegion(
                center: annotation.coordinate,
                latitudinalMeters: 1000, longitudinalMeters: 1000)
        default:
            var topLeft = CLLocationCoordinate2D(
              latitude: -90,
              longitude: 180)
            var bottomRight = CLLocationCoordinate2D(
              latitude: 90,
              longitude: -180)

            for annotation in annotations {
              topLeft.latitude = max(topLeft.latitude,
                                     annotation.coordinate.latitude)
              topLeft.longitude = min(topLeft.longitude,
                                      annotation.coordinate.longitude)
              bottomRight.latitude = min(bottomRight.latitude,
                                         annotation.coordinate.latitude)
              bottomRight.longitude = max(
                bottomRight.longitude,
                annotation.coordinate.longitude)
            }

            let center = CLLocationCoordinate2D(
              latitude: topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2,
              longitude: topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2)

            let extraSpace = 1.2
            let span = MKCoordinateSpan(
              latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) * extraSpace,
              longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace)
            
            region = MKCoordinateRegion(center: center,
                                        span: span)
        }
        
        return mapView.regionThatFits(region)
    }
    
    @objc func showLocationDetail(_ sender: UIButton) {
        performSegue(withIdentifier: "EditLocationFromMap", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let button = sender as! UIButton
        let index = button.tag
        if segue.identifier == "EditLocationFromMap" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            controller.locationToEdit = locations[index]
        }
    }

}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Location else { return nil}
        
        let identifier = "LocationAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(
            withIdentifier: identifier)
        
        if annotationView == nil {
            let markerAnnotationView = MKMarkerAnnotationView(
                annotation: annotation,
                reuseIdentifier: identifier)
            
            markerAnnotationView.isEnabled = true
            markerAnnotationView.canShowCallout = true
            markerAnnotationView.animatesWhenAdded = false
            markerAnnotationView.markerTintColor = UIColor(
                red: 0.82,
                green: 0.32,
                blue: 0.62,
                alpha: 1)
            
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.addTarget(self,
                                  action: #selector(showLocationDetail(_:)),
                                  for: .touchUpInside)
            markerAnnotationView.rightCalloutAccessoryView = rightButton
            annotationView = markerAnnotationView
        }
        
        if let annotationView = annotationView {
            annotationView.annotation = annotation
            let rightButton = annotationView.rightCalloutAccessoryView as! UIButton
            if let index = locations.firstIndex(of: annotation as! Location) {
                rightButton.tag = index
            }
        }
        
        return annotationView
    }
}
