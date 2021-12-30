//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Xiao Quan on 12/29/21.
//

import Foundation
import UIKit

class CategoryPickerViewController: UITableViewController {
    
    let categories = [
      "No Category",
      "Apple Store",
      "Bar",
      "Bookstore",
      "Club",
      "Grocery Store",
      "Historic Building",
      "House",
      "Icecream Vendor",
      "Landmark",
      "Nature",
      "School",
      "Park"
    ]
    
    var selectedIndex = 0
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "returnToTagDetails" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell) {
                if indexPath.row == selectedIndex {
                    return
                }
                
                let currentSelectionIndexPath = IndexPath(row: selectedIndex, section: 0)
                
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                tableView.cellForRow(at: currentSelectionIndexPath)?.accessoryType = .none
                
                selectedIndex = indexPath.row
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row]
        if indexPath.row == selectedIndex {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
}
