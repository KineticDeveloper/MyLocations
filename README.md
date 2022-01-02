# My Locations

### Getting Started Using Core Location

- A CLLocationManager() performs the location updating
- It sends its updates to its delegate, so make sure to set it up before doing anything else
- Get permission using the manager first. "while in use" is enough. 
- If user ever denies it, make sure we handle the permission status to get permission before anything else. This can be an alert if authorizationStatus is .denied or .restricted
- Set locationManager's desired accuracy. Options start with kCLLocation###. 
- Call locationManager.startUpdatingLocation() to get location info and send it to the delegate. 
- In the delegate, use the location as you see fit (update UI)


### Error Handling
GPS services is prone to errors. Use an instance variable to store any errors received from delegate. Then, make sure the following are taken care of:

1. Location services restricted from error code
2. Location services restricted from CLLocationManager
3. Currently updating location, waiting for more accurate results
4. First time using the app. Tap 'Get My Location' to Start".


### Reverse Geocoding (CLGeocoder)
Setup instance variables to store current state, errors, and results.
 
- use geoCoder.reverseGeocodeLocation to decode and handle results and errors.
- update UI based on error code and results. 

### Improving results

- If accuracy is not within desired accuracy, see if the locations move within 10 meters in 10 seconds. If so, update address and done. 

- Add a timeout timer if we are waiting too long for a result. 

#### Short Summary

- A lot of work is done to make sure that the UI is updated appropriately depending on the state of location update and reverse geocoding. To account for different errors and the delays for accurate results, we need instance variables to keep track of these changes.
-  The `updateLabels()` function is called whenever we need to update the UI and it looks at the state of the instance variables to decide what to display

### Misc

- Unwind segues will not trigger `viewDidLoad()`

---

### Creating Custom UIViews (HUD)

- subclass from UIView, which has a `(frame: )` initializer to setup an empty view with the same size as frame (which can be obtained using .bounds on any other view). 
- Therefore, to create a hud view, we will need a parent view to sit in. It's convenience initializer will need a `(inView view: UIView)`.
- Once parent view is obtained, create a new hud view with the bounds of the parent, then disable interaction of parent, add subview to parent using `.addSubView(_ view: UIView)`
- Set what the view should look like and return the view. 

##### When using the view

- The parent view should be the oldest parent... to cover the whole screen. 
- Use .view on a view controller to obtain its view. 


##### Designing custom shape for custom view

- override `draw(_ rect: CGRect)` function

Draw a rectangle:

- `CGRect(x, y, width, height)`

Draw a rounded rectange:

- `UIBezierPath(roundedRect, corderRadius)`

Fill Color

- `UIColer(coler, alpha).setFill()`
	- This prepares the color for the subsequent .fill() operation
- `{shape}.fill()`

Draw an image: 

- declare the top left point where the image should be drawn.
	- use `CGPoint(x, y)`
- Use `image.draw(at: CGPoint)` to draw the image

Draw a text:

- Make an `NSAttributedString.Key` dict to instruct what the text should look like. e.g. 

	```
	let attribs = [ 
	    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
	    NSAttributedString.Key.foregroundColor: UIColor.white
	]
	```

- get the size of the text: 

	```
	let textSize = text.size(withAttributes: attribs)
	```
	
- same as image, get the top left CGPoint where the text should be drawn.
- Then call `text.draw(at: CGPoint, withAttributes: [NSAttributedString.Key: Value])`


---

### UIView Animation

- Set initial look and a transform, e.g. 

	```
	alpha = 0
	transform = CGAffineTransfrom(...)
	```
	
- Then call `UIView.animate(...) { end look of self view }`


### Remove hud from parent

- call `removeFromSuperView()`

---

### Using CoreData

- Create an entity
- Create a `NSManagedObjectContext` at a high level such as AppDelegate or SceneDelegate
- Permeate the context down to views that needs saving and fetching. 

##### To Save:
 
- Create and load up an entity object
- Call `managedObjectContext.save()`

##### To Load:
	
- Create an `NSFetchRequest<Entity>()`
- Give it a sort descriptor `NSSortDescriptor`
	- `request.sortDescriptor = [sortDescriptor]`
- Assign the output of the fetch operation in an instance variable, in a do-try-catch block

### Using NSFetchedResultsController

##### Create one as follows:

```
lazy var fetchedResultController: NSFetchedResultsController<Location> = {

			// Setup Fetch Request
        let fetchRequest = NSFetchRequest<Location>(entityName: "Location")
        let dateDescriptor = NSSortDescriptor(
            key: "date",
            ascending: true)
        let categoryDescriptor = NSSortDescriptor(
            key: "category",
            ascending: true
        )
        fetchRequest.sortDescriptors = [
            categoryDescriptor,
            dateDescriptor,
        ]
        
        fetchRequest.fetchBatchSize = 20
        
        // Initialize the fetchedResultController using the fetch request
        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: "category",
            cacheName: "Locations")
        
        fetchedResultController.delegate = self
        return fetchedResultController
    }()
```

##### Delegate Methods (semi-boiler plate to use with tableViews)

```
extension LocationsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("fetchController will change content")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
                let location = controller.object(at: indexPath!) as! Location
                cell.configure(with: location)
            }
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        @unknown default:
            print("*** NSFetchedResults unknown type")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case.insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case.delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
          print("*** NSFetchedResultsChangeUpdate (section)")
        case .move:
          print("*** NSFetchedResultsChangeMove (section)")
        @unknown default:
          print("*** NSFetchedResults unknown type")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}
```