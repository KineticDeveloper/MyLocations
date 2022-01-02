//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by Xiao Quan on 1/1/22.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var locationDescription: String
    @NSManaged public var category: String
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var address: String
    @NSManaged public var date: Date

}

extension Location : Identifiable {

}