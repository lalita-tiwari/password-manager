//
//  prj1App.swift
//  prj1
//
//  Created by Lalita Tiwari on 9/20/22.
//

import SwiftUI

@main
struct password_managerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext).navigationTitle("Password Vault")
        }
    }
}
    
