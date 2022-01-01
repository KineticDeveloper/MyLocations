//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Xiao Quan on 1/1/22.
//

import Foundation
import UIKit
import CoreData

class LocationsViewController: UITableViewController {
    
    var locations: [Location] = []
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest<Location>(entityName: "Location")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            try self.locations = managedObjectContext.fetch(fetchRequest)
        } catch {
            fatalError("Failed to fetch location detail: \(error)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell")!
        
        let description = cell.viewWithTag(100)! as! UILabel
        let address = cell.viewWithTag(101)! as! UILabel
        
        description.text = locations[indexPath.row].locationDescription
        address.text = locations[indexPath.row].address
        
        return cell
    }
}
