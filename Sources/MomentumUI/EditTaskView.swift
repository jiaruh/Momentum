import SwiftUI
import SwiftData
import PhotosUI
import UIKit
import MomentumCore

public struct EditTaskView: View {
    public let item: Item
    @Environment(\.presentationMode) var presentationMode
    
    @State private var task: String = ""
    @State private var priority: TaskPriority = .normal
    @State private var dueDate = Date()
    @State private var detailsText: String = ""
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var hasDueDate: Bool = false
    
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
        
        presentationMode.wrappedValue.dismiss()
    }
}