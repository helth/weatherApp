//
//  ForeFlightApp.swift
//  ForeFlight
//
//  Created by Frederik Helth on 21/01/2024.
//

import SwiftUI

@main
struct ForeFlightApp: App {
    @StateObject private var persistenceController = PersistenceController()

    var body: some Scene {
        WindowGroup {
            WeatherListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
