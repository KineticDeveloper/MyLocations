//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Xiao Quan on 12/29/21.
//

import UIKit
import CoreLocation
import CoreData

private let dateFormat: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

class LocationDetailsViewController: UITableViewController {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: Instance Variables
    
    var managedObjectContext: NSManagedObjectContext!
    
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                self.descriptionText = location.locationDescription
                self.selectedCategory = location.category
                self.coordinates = CLLocationCoordinate2DMake(location.latitude,
                                                              location.longitude)
                self.address = location.address
                self.date = location.date
                isInEditMode = true
            }
        }
    }
    var isInEditMode = false
    var coordinates = CLLocationCoordinate2D(
        latitude: 0.0,
        longitude: 0.0)
    var address: String!
    var date: Date!
    var selectedCategory = "No Category"
    var descriptionText = ""
    
    // MARK: View Lifecycle
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            if let index = controller.categories.firstIndex(of: selectedCategory) {
                controller.selectedIndex = index
            }
        }
    }
    
    @IBAction func categoryPickerDidPick(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController
        let selectedIndex = controller.selectedIndex
        selectedCategory = controller.categories[selectedIndex]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = isInEditMode ? "Edit Location" : "Tag Location"
        self.descriptionTextView.text = descriptionText
        self.latitudeLabel.text = String.init(format: "%.8f",
                                         coordinates.latitude)
        self.longitudeLabel.text = String.init(format: "%.8f",
                                         coordinates.longitude)
        self.addressLabel.text = address
        self.dateLabel.text = dateFormat.string(from: date)
        
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(resignKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.categoryLabel.text = selectedCategory
        
    }
    
    // MARK: - User Actions
    
    @objc func resignKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        if indexPath == nil || !(indexPath!.row == 0 && indexPath!.section == 0) {
            print("Tapped outside of first row first section")
            descriptionTextView.resignFirstResponder()
        }
    }

    @IBAction func done() {
        guard let mainView = navigationController?.parent?.view else { return }
        let hud = HudView.hud(inView: mainView, animated: true)
        
        hud.text = isInEditMode ? "Updated" : "Tagged"
        
        let location = isInEditMode ?
                        locationToEdit! :
                        Location(context: managedObjectContext)
        location.locationDescription = descriptionTextView.text
        location.category = selectedCategory
        location.latitude = coordinates.latitude
        location.longitude = coordinates.longitude
        location.address = address
        location.date = date
        
        do {
            try managedObjectContext.save()
            runAfter(seconds: 0.6) {
                hud.exit()
                self.navigationController?.popViewController(animated: true)
            }
        } catch {
            fatalError("Error: \(error)")
        }
        
        isInEditMode = false
    }
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: Table View
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            self.descriptionTextView.becomeFirstResponder()
        }
    }
}
