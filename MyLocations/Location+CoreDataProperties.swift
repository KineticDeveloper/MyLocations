//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by Xiao Quan on 1/1/22.
//
//

import Foundation
import CoreData
import MapKit


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }
    
    @nonobjc class func nextPhotoID() -> Int {
        let id = UserDefaults.standard.integer(forKey: "photo_id")
        UserDefaults.standard.set(id + 1, forKey: "photo_id")
        return id
    }

    @NSManaged public var locationDescription: String
    @NSManaged public var category: String
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var address: String
    @NSManaged public var date: Date
    
    @NSManaged public var photoID: NSNumber?
    
    var hasPhoto: Bool {
        photoID != nil
    }
    
    var photoURL: URL {
        assert(photoID != nil, "No Photo ID set")
        let id = photoID!
        let filename = "Photo-\(id.intValue).jpeg"
        return applicationDocumentsDirectory.appendingPathComponent(filename)
    }
    
    var photoImage: UIImage? {
        if photoID != nil {
            return UIImage(contentsOfFile: photoURL.path)
        }
        return nil
    }
    
    func removeImage() {
        if hasPhoto {
            do {
                try FileManager.default.removeItem(at: photoURL)
            } catch {
                print("Error deleting image: \(error)")
            }
        }
    }
    
}

extension Location : Identifiable, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude)
    }
    
    public var title: String? {
        return locationDescription
    }
    
    public var subtitle: String? {
        return category
    }
}
