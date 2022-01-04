//
//  Utils.swift
//  MyLocations
//
//  Created by Xiao Quan on 12/30/21.
//

import Foundation
import CoreLocation

let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask)
    return paths[0]
}()

let dateFormat: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

func runAfter(seconds: Double, operation: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(
        deadline: .now() + seconds,
        execute: operation)
}

func getAddressFromPlacemark(from placemark: CLPlacemark) -> String {
    var lineOne = ""
    lineOne.add(placemark.subThoroughfare)
    lineOne.add(placemark.thoroughfare, separatedBy: " ")

    var lineTwo = ""
    lineTwo.add(placemark.locality)
    lineTwo.add(placemark.administrativeArea, separatedBy: " ")
    lineTwo.add(placemark.postalCode, separatedBy: " ")
    lineTwo.add(placemark.country, separatedBy: " ")
    lineOne.add(lineTwo, separatedBy: "\n")
    
    return lineOne
}
