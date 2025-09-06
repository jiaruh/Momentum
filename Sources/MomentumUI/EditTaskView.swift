import SwiftUI
import SwiftData
import PhotosUI
import UIKit
import MomentumCore

/// A form-based view for editing existing tasks.
///
/// `EditTaskView` provides a comprehensive interface for modifying all aspects
/// of a task including its name, priority, due date, description, and image attachments.
///
/// ## Features
///
/// - Task name editing
/// - Priority level selection
/// - Optional due date setting
/// - Multi-line description editing
/// - Image attachment management (add/change/remove)
/// - Form validation
/// - Cancel and save functionality
///
/// ## Usage
///
/// ```swift
/// .sheet(isPresented: $showingEdit) {
///     EditTaskView(item: taskToEdit)
/// }
/// ```
///
/// ## Modal Presentation
///
/// ```swift
/// @State private var showingEditView = false
///
/// Button("Edit Task") {
///     showingEditView = true
/// }
/// .sheet(isPresented: $showingEditView) {
///     EditTaskView(item: selectedTask)
/// }
/// ```
public struct EditTaskView: View {
    /// The task item to edit.
    public let item: Item
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var task: String = ""
    @State private var priority: TaskPriority = .normal
    @State private var dueDate = Date()
    @State private var detailsText: String = ""
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var hasDueDate: Bool = false
    
    // Reminder-related state
    @State private var reminderEnabled: Bool = false
    @State private var reminderDate = Date()
    @State private var isRepeating: Bool = false
    @State private var repeatInterval: RepeatInterval = .none
    
    /// Creates a new edit task view.
    ///
    /// The view will be pre-populated with the current values from the provided task item.
    ///
    /// - Parameter item: The task item to edit.
    public init(item: Item) {
        self.item = item
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task name", text: $task)
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    
                    Toggle("Set Due Date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    }
                }
                
                Section(header: Text("Reminder")) {
                    Toggle("Enable Reminder", isOn: $reminderEnabled)
                    
                    if reminderEnabled {
                        DatePicker("Reminder Time", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                        
                        Toggle("Repeat", isOn: $isRepeating)
                        
                        if isRepeating {
                            Picker("Repeat Interval", selection: $repeatInterval) {
                                ForEach(RepeatInterval.allCases) { interval in
                                    Text(interval.rawValue).tag(interval)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Additional Details")) {
                    TextField("Description or notes", text: $detailsText, axis: .vertical)
                        .lineLimit(3...6)
                    
                    PhotosPicker("Change Image", selection: $selectedImageItem, matching: .images)
                        .onChange(of: selectedImageItem) { newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                    imageData = data
                                }
                            }
                        }
                    
                    if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                    } else if let existingImageData = item.imageData, let uiImage = UIImage(data: existingImageData) {
                        VStack {
                            Text("Current Image")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 200)
                                .cornerRadius(8)
                            Button("Remove Image") {
                                imageData = Data() // Empty data to indicate removal
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
                
                Section {
                    Button("Save Changes") {
                        saveChanges()
                    }
                    .disabled(task.isEmpty)
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadCurrentValues()
        }
    }
    
    private func loadCurrentValues() {
        task = item.task
        if let itemPriority = item.priority {
            priority = TaskPriority(rawValue: itemPriority) ?? .normal
        }
        if let itemDueDate = item.dueDate {
            dueDate = itemDueDate
            hasDueDate = true
        }
        detailsText = item.detailsText ?? ""
        imageData = item.imageData
        
        // Load reminder-related values
        reminderEnabled = item.reminderEnabled
        if let itemReminderDate = item.reminderDate {
            reminderDate = itemReminderDate
        }
        isRepeating = item.isRepeating
        repeatInterval = item.repeatInterval ?? .none
    }
    
    private func saveChanges() {
        item.task = task
        item.priority = priority.rawValue
        item.dueDate = hasDueDate ? dueDate : nil
        item.detailsText = detailsText.isEmpty ? nil : detailsText
        
        // Handle image data
        if let newImageData = imageData {
            if newImageData.isEmpty {
                // Remove image
                item.imageData = nil
            } else {
                // Update with new image
                item.imageData = newImageData
            }
        }
        
        // Handle reminder settings
        if reminderEnabled {
            // Generate reminder ID if not exists
            if item.reminderId == nil {
                item.reminderId = NotificationManager.shared.generateReminderId()
            }
            item.reminderEnabled = true
            item.reminderDate = reminderDate
            item.isRepeating = isRepeating
            item.repeatInterval = isRepeating ? repeatInterval : nil
            
            // Schedule notification
            Task {
                await NotificationManager.shared.scheduleTaskReminder(for: item)
            }
        } else {
            // Disable reminder and cancel notification
            item.reminderEnabled = false
            item.reminderDate = nil
            item.isRepeating = false
            item.repeatInterval = nil
            
            // Cancel existing notification
            NotificationManager.shared.cancelTaskReminder(for: item)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}