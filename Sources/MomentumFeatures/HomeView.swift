import SwiftUI
import SwiftData
import PhotosUI
import UIKit
import MomentumCore
import MomentumUI

public struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.createdAt, order: .reverse) private var items: [Item]

    @State private var showingAddTaskView = false

    public init() {}

    public var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    List {
                        ForEach(items) { item in
                            TaskRow(item: item)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(PlainListStyle())
                }
                .navigationTitle("My Tasks")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
                .sheet(isPresented: $showingAddTaskView) {
                    AddTaskView()
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddTaskView.toggle()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 10)
                        }
                        .padding()
                    }
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var task: String = ""
    @State private var priority: TaskPriority = .normal
    @State private var dueDate = Date()
    @State private var detailsText: String = ""
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var imageData: Data?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task name", text: $task)
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
                
                Section(header: Text("Additional Details")) {
                    TextField("Description or notes", text: $detailsText, axis: .vertical)
                        .lineLimit(3...6)
                    
                    PhotosPicker("Add Image", selection: $selectedImageItem, matching: .images)
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
                    }
                }
                
                Section {
                    Button("Add Task") {
                        addItem()
                    }
                    .disabled(task.isEmpty)
                }
            }
            .navigationTitle("Add New Task")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(
                task: task,
                dueDate: dueDate,
                priority: priority.rawValue,
                detailsText: detailsText.isEmpty ? nil : detailsText,
                imageData: imageData
            )
            modelContext.insert(newItem)
            presentationMode.wrappedValue.dismiss()
        }
    }
}