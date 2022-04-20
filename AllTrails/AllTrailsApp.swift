//
//  AllTrailsApp.swift
//  AllTrails
//
//  Created by Prince Ugwuh on 4/19/22.
//

import SwiftUI

@main
struct AllTrailsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
