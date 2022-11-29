//
//  password_managerApp.swift
//  password-manager
//
//  Created by Lokesh Belwal on 11/29/22.
//

import SwiftUI

@main
struct password_managerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
