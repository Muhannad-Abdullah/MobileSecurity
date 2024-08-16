//
//  MobileSecurityApp.swift
//  MobileSecurity
//
//  Created by Asma Work on 12/02/1446 AH.
//

import SwiftUI

@main
struct MobileSecurityApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
