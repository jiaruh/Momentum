//
//  MomentumApp.swift
//  Momentum
//
//  Created by jiaruh on 2/8/2025.
//

import SwiftUI
import SwiftData
import UserNotifications
import MomentumCore
import MomentumFeatures

@main
struct MomentumApp: App {
    
    // Notification handler instance
    private let notificationHandler = NotificationHandler()
    
    init() {
        setupNotificationCategories()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    setupNotifications()
                }
        }
        .modelContainer(for: Item.self)
    }
    
    // MARK: - Notification Setup
    
    /// Sets up notification categories for actionable notifications.
    private func setupNotificationCategories() {
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE",
            title: "Complete",
            options: []
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "Snooze 10 min",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "TASK_REMINDER",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        // Set the notification delegate
        UNUserNotificationCenter.current().delegate = notificationHandler
    }
    
    /// Requests notification authorization and sets up initial notifications.
    private func setupNotifications() {
        Task {
            let granted = await NotificationManager.shared.requestAuthorization()
            if granted {
                print("Notification authorization granted")
                // Here you could reschedule existing notifications
                // after app restart if needed
            } else {
                print("Notification authorization denied")
            }
        }
    }
}
