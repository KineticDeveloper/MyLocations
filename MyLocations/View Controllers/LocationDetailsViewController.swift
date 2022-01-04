//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Xiao Quan on 12/29/21.
//

import UIKit
import CoreLocation
import CoreData

class LocationDetailsViewController: UITableViewController {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var addImageLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
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
            }
        }
    }
    var isInEditMode: Bool {
        locationToEdit != nil
    }
    var coordinates = CLLocationCoordinate2D(
        latitude: 0.0,
        longitude: 0.0)
    var address: String!
    var date: Date!
    var selectedCategory = "No Category"
    var descriptionText = ""
    
    var image: UIImage?
    
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
        descriptionTextView.layer.cornerRadius = 10
        title = isInEditMode ? "Edit Location" : "Tag Location"
        self.descriptionTextView.text = descriptionText
        self.latitudeLabel.text = String.init(format: "%.8f",
                                         coordinates.latitude)
        self.longitudeLabel.text = String.init(format: "%.8f",
                                         coordinates.longitude)
        self.addressLabel.text = address
        self.dateLabel.text = dateFormat.string(from: date)
        if let location = locationToEdit {
            if location.hasPhoto {
                if let image = location.photoImage {
                    self.showImage(image)
                }
            }
        }
        
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
        
        if !isInEditMode { location.photoID = nil }
        
        if let image = image {
            if !location.hasPhoto {
                let id = Location.nextPhotoID()
                location.photoID = id as NSNumber
            }
            
            if let data = image.jpegData(compressionQuality: 0.5) {
                let url = location.photoURL
                print(url)
                do {
                    try data.write(to: url, options: .atomic)
                } catch {
                    print("Error Saving Image to URL: \(error.localizedDescription)")
                }
            }
        }
        
        do {
            try managedObjectContext.save()
            runAfter(seconds: 0.6) {
                hud.exit()
                self.navigationController?.popViewController(animated: true)
            }
        } catch {
            fatalError("Error: \(error)")
        }
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
        
        if indexPath.section == 1 && indexPath.row == 0 {
            choosePhoto()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// MARK: - ImagePicker
extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func choosePhoto() {
        if true || UIImagePickerController.isSourceTypeAvailable(.camera) {
            presentChooseImageActions()
        } else {
            choosePhotoFromImageLibrary()
        }
    }
    
    func presentChooseImageActions() {
        let alert = UIAlertController(
            title: "Choose Image From:",
            message: nil,
            preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil)
        
        let fromLibraryAction = UIAlertAction(
            title: "Photo Library",
            style: .default) { _ in
                self.choosePhotoFromImageLibrary()
            }
        
        let fromCameraAction = UIAlertAction(
            title: "Camera",
            style: .default) { _ in
                self.choosePhotoFromCamera()
            }
    
        alert.addAction(cancelAction)
        alert.addAction(fromLibraryAction)
        alert.addAction(fromCameraAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func choosePhotoFromImageLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true) {
            if let image = info[.editedImage] as? UIImage {
                self.image = image
                self.showImage(image)
            }
        }
    }
    
    func showImage(_ image: UIImage) {
        let aspectRatio = image.size.width / image.size.height
        
        imageView.image = image
        imageHeight.constant = 260 / aspectRatio
        imageView.layer.cornerRadius = imageHeight.constant / 4
        imageView.clipsToBounds = true
        imageView.isHidden = false
        addImageLabel.text = ""
        tableView.reloadData()
    }
}
