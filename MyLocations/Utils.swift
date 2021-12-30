//
//  Utils.swift
//  MyLocations
//
//  Created by Xiao Quan on 12/30/21.
//

import Foundation

func runAfter(seconds: Double, operation: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(
        deadline: .now() + seconds,
        execute: operation)
}
