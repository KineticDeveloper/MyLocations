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


### Reverse Geocoding (CLGeocoder)



