import Foundation
import UIKit
import UserNotifications
import MomentumCore

/// Manages local notifications for task reminders.
///
/// `NotificationManager` handles all aspects of local notification management,
/// including authorization requests, scheduling, canceling, and handling user interactions.
///
/// ## Features
///
/// - Request notification authorization from users
/// - Schedule and cancel task reminders
/// - Support for recurring reminders
/// - Handle notification interactions
/// - Generate unique reminder identifiers
///
/// ## Usage
///
/// ```swift
/// // Request authorization
/// let granted = await NotificationManager.shared.requestAuthorization()
///
/// // Schedule a reminder
/// await NotificationManager.shared.scheduleTaskReminder(for: task)
///
/// // Cancel a reminder
/// NotificationManager.shared.cancelTaskReminder(for: task)
/// ```
public class NotificationManager: ObservableObject {
    
    /// Shared instance for singleton access.
    public static let shared = NotificationManager()
    
    /// Private initializer to ensure singleton pattern.
    private init() {
        setupNotificationCategories()
    }
    
    // MARK: - Authorization
    
    /// Requests notification authorization from the user.
    ///
    /// This method should be called when the app launches to request permission
    /// to send local notifications to the user.
    ///
    /// - Returns: `true` if authorization was granted, `false` otherwise.
    @MainActor
    public func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            if granted {
                await registerForRemoteNotifications()
            }
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    /// Registers for remote notifications (for badge updates).
    @MainActor
    private func registerForRemoteNotifications() async {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    // MARK: - Notification Scheduling
    
    /// Schedules a local notification for a task reminder.
    ///
    /// - Parameter task: The task for which to schedule a reminder.
    @MainActor
    public func scheduleTaskReminder(for task: Item) async {
        guard let reminderDate = task.reminderDate,
              task.reminderEnabled,
              let reminderId = task.reminderId else {
            return
        }
        
        // Cancel any existing notification for this task
        cancelTaskReminder(for: task)
        
        let content = createNotificationContent(for: task)
        let trigger = createNotificationTrigger(for: task)
        
        let request = UNNotificationRequest(
            identifier: reminderId,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Scheduled reminder for task: \(task.task)")
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }
    
    /// Cancels a scheduled notification for a task reminder.
    ///
    /// - Parameter task: The task for which to cancel the reminder.
    public func cancelTaskReminder(for task: Item) {
        guard let reminderId = task.reminderId else { return }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [reminderId]
        )
        print("Cancelled reminder for task: \(task.task)")
    }
    
    /// Cancels all pending notifications.
    public func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Cancelled all reminders")
    }
    
    // MARK: - Notification Content
    
    /// Creates notification content for a task.
    ///
    /// - Parameter task: The task to create content for.
    /// - Returns: Configured `UNMutableNotificationContent`.
    private func createNotificationContent(for task: Item) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        
        content.title = "Task Reminder"
        content.body = task.task
        content.sound = .default
        
        // Add task information for handling interactions
        content.userInfo = [
            "taskId": task.reminderId ?? "",
            "taskTitle": task.task,
            "isRepeating": task.isRepeating
        ]
        
        // Set category identifier for actionable notifications
        content.categoryIdentifier = "TASK_REMINDER"
        
        // Add subtitle with priority if available
        if let priority = task.priority {
            content.subtitle = "Priority: \(priority)"
        }
        
        return content
    }
    
    /// Creates notification trigger for a task.
    ///
    /// - Parameter task: The task to create trigger for.
    /// - Returns: Configured `UNNotificationTrigger`.
    private func createNotificationTrigger(for task: Item) -> UNNotificationTrigger {
        guard let reminderDate = task.reminderDate else {
            return UNTimeIntervalNotificationTrigger(timeInterval: 0, repeats: false)
        }
        
        // For repeating notifications, we need to adjust the trigger based on the repeat interval
        if task.isRepeating, let repeatInterval = task.repeatInterval {
            switch repeatInterval {
            case .daily:
                let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
                return UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
            case .weekly:
                let triggerDate = Calendar.current.dateComponents([.weekday, .hour, .minute], from: reminderDate)
                return UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
            case .monthly:
                let triggerDate = Calendar.current.dateComponents([.day, .hour, .minute], from: reminderDate)
                return UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
            case .yearly:
                let triggerDate = Calendar.current.dateComponents([.month, .day, .hour, .minute], from: reminderDate)
                return UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
            default:
                break
            }
        }
        
        // For one-time notifications or unsupported repeat intervals
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )
        
        return UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: false
        )
    }
    
    // MARK: - Helper Methods
    
    /// Generates a unique identifier for task reminders.
    ///
    /// - Returns: A unique string identifier.
    public func generateReminderId() -> String {
        return UUID().uuidString
    }
    
    /// Checks if a reminder is scheduled for a specific task.
    ///
    /// - Parameter task: The task to check.
    /// - Returns: `true` if a reminder is scheduled, `false` otherwise.
    public func isReminderScheduled(for task: Item) async -> Bool {
        guard let reminderId = task.reminderId else { return false }
        
        let pendingNotifications = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return pendingNotifications.contains { $0.identifier == reminderId }
    }
    
    /// Returns all pending notification requests.
    ///
    /// - Returns: Array of pending `UNNotificationRequest` objects.
    public func getPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
    
    // MARK: - Notification Categories
    
    /// Sets up notification categories for actionable notifications.
    private func setupNotificationCategories() {
        // Notification categories are now set up in MomentumApp.swift
        // This method is kept for future use if needed
    }
}

// MARK: - Notification Handler

/// Handles notification interactions and user responses.
public class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    
    /// Called when a notification is delivered to a foreground app.
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Called when the user interacts with a notification.
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let taskId = userInfo["taskId"] as? String,
           let taskTitle = userInfo["taskTitle"] as? String {
            
            switch response.actionIdentifier {
            case "COMPLETE":
                handleCompleteAction(taskId: taskId, taskTitle: taskTitle)
            case "SNOOZE":
                handleSnoozeAction(taskId: taskId, taskTitle: taskTitle)
            case UNNotificationDefaultActionIdentifier:
                // User tapped the notification
                handleNotificationTap(taskId: taskId, taskTitle: taskTitle)
            default:
                break
            }
        }
        
        completionHandler()
    }
    
    /// Handles the complete action from a notification.
    private func handleCompleteAction(taskId: String, taskTitle: String) {
        print("Marking task as complete: \(taskTitle)")
        // This would be handled by the app's main view model
        // through a notification system or deep linking
    }
    
    /// Handles the snooze action from a notification.
    private func handleSnoozeAction(taskId: String, taskTitle: String) {
        print("Snoozing task: \(taskTitle)")
        // Schedule a new notification 10 minutes from now
        let snoozeDate = Date().addingTimeInterval(600) // 10 minutes
        
        // This would require finding the task and updating its reminder date
        // through the app's data management system
    }
    
    /// Handles when the user taps on a notification.
    private func handleNotificationTap(taskId: String, taskTitle: String) {
        print("User tapped notification for task: \(taskTitle)")
        // Navigate to the task detail view
        // This would be handled by the app's navigation system
    }
}
