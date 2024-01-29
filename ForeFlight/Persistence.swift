//
//  Persistence.swift
//  ForeFlight
//
//  Created by Frederik Helth on 21/01/2024.
//

import CoreData
import Foundation

class PersistenceController: ObservableObject {
    // Load our data model
    let container = NSPersistentContainer(name: "ForeFlight")
    
    init() {
        container.loadPersistentStores(completionHandler: {
            description, error in
            if let error = error {
                print("Core data failed to load: \(error.localizedDescription)")
            }
        })
    }
}
