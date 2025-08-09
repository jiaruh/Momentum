//
//  MomentumApp.swift
//  Momentum
//
//  Created by jiaruh on 2/8/2025.
//

import SwiftUI
import SwiftData

@main
struct MomentumApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Item.self)
    }
}
