//
//  MomentumApp.swift
//  Momentum
//
//  Created by jiaruh on 2/8/2025.
//

import SwiftUI
import CoreData

@main
struct MomentumApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
