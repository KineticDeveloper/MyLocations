//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Xiao Quan on 12/29/21.
//

import UIKit
import CoreLocation

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
    
    var coordinates = CLLocationCoordinate2D(
        latitude: 0.0,
        longitude: 0.0)
    var address: String!
    var date: Date!
    var selectedCategory = "No Category"
    
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
    
    @objc func resignKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        if indexPath == nil || !(indexPath!.row == 0 && indexPath!.section == 0) {
            print("Tapped outside of first row first section")
            descriptionTextView.resignFirstResponder()
        }
    }

    @IBAction func done() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
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
