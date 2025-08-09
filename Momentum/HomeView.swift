//
//  ContentView.swift
//  Momentum
//
//  Created by jiaruh on 2/8/2025.
//

import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.createdAt, order: .reverse) private var items: [Item]

    @State private var showingAddTaskView = false

    public init() {}

    var body: some View {
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

struct TaskRow: View {
    let item: Item
    @State private var showingEditTaskView = false
    
    var body: some View {
        HStack {
            Button(action: {
                item.isCompleted.toggle()
            }) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? .green : .primary)
            }
            .buttonStyle(PlainButtonStyle())

            VStack(alignment: .leading) {
                Text(item.task)
                    .strikethrough(item.isCompleted, color: .primary)
                    .foregroundColor(item.isCompleted ? .secondary : .primary)
                
                if let detailsText = item.detailsText, !detailsText.isEmpty {
                    Text(detailsText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                if item.imageData != nil {
                    HStack {
                        Image(systemName: "photo")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("Image attached")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                if let dueDate = item.dueDate {
                    Text("Due: \(dueDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let priority = item.priority {
                    Text("Priority: \(priority)")
                        .font(.caption)
                        .foregroundColor(priorityColor(for: priority))
                }
            }
            
            Spacer()
            
            Button(action: {
                showingEditTaskView.toggle()
            }) {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())

            NavigationLink(destination: TaskDetailView(item: item)) {
                Image(systemName: "chevron.right.circle.fill")
                    .foregroundColor(.gray)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        .sheet(isPresented: $showingEditTaskView) {
            EditTaskView(item: item)
        }
    }
    
    private func priorityColor(for priority: String) -> Color {
        switch priority {
        case "High":
            return .red
        case "Normal":
            return .orange
        case "Low":
            return .green
        default:
            return .primary
        }
    }
    
    
}

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var task: String = ""
    @State private var priority: Priority = .normal
    @State private var dueDate = Date()
    @State private var detailsText: String = ""
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var imageData: Data?

    enum Priority: String, CaseIterable, Identifiable {
        case low = "Low"
        case normal = "Normal"
        case high = "High"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task name", text: $task)
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases) { priority in
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
                    
                    if let imageData = imageData,
                       let uiImage = UIImage(data: imageData) {
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
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(
                task: task,
                isCompleted: false,
                dueDate: dueDate,
                priority: priority.rawValue,
                editedAt: nil,
                detailsText: detailsText.isEmpty ? nil : detailsText,
                imageData: imageData
            )
            modelContext.insert(newItem)
            
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct EditTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Bindable var item: Item
    @State private var tempDetailsText: String = ""
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var tempImageData: Data?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task name", text: $item.task)
                    
                    Picker("Priority", selection: $item.priority) {
                        ForEach(AddTaskView.Priority.allCases) { priority in
                            Text(priority.rawValue).tag(priority.rawValue as String?)
                        }
                    }
                    
                    DatePicker("Due Date", selection: Binding(get: { item.dueDate ?? Date() }, set: { item.dueDate = $0 }), displayedComponents: .date)
                }
                
                Section(header: Text("Additional Details")) {
                    TextField("Description or notes", text: $tempDetailsText, axis: .vertical)
                        .lineLimit(3...6)
                        .onAppear {
                            tempDetailsText = item.detailsText ?? ""
                            tempImageData = item.imageData
                        }
                    
                    PhotosPicker("Change Image", selection: $selectedImageItem, matching: .images)
                        .onChange(of: selectedImageItem) { newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                    tempImageData = data
                                }
                            }
                        }
                    
                    if let imageData = tempImageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                    }
                    
                    if tempImageData != nil {
                        Button(role: .destructive) {
                            tempImageData = nil
                        } label: {
                            Label("Remove Image", systemImage: "trash")
                        }
                    }
                }
                
                Section {
                    Button("Save Changes") {
                        item.detailsText = tempDetailsText.isEmpty ? nil : tempDetailsText
                        item.imageData = tempImageData
                        item.editedAt = Date()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(item.task.isEmpty)
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Item.self, inMemory: true)
}

struct TaskDetailView: View {
    let item: Item
    @State private var showingEdit = false

    private func priorityColor(for priority: String) -> Color {
        switch priority {
        case "High": return .red
        case "Normal": return .orange
        case "Low": return .green
        default: return .primary
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    Text(item.task)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    if let priority = item.priority {
                        Text(priority)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(priorityColor(for: priority).opacity(0.15))
                            .foregroundColor(priorityColor(for: priority))
                            .cornerRadius(8)
                    }
                }

                if let dueDate = item.dueDate {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        Text("Due: \(dueDate, style: .date)")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                }

                if let details = item.detailsText, !details.isEmpty {
                    Text(details)
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }

                if let data = item.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                }

                Spacer(minLength: 0)
            }
            .padding()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.08), Color.purple.opacity(0.12)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
        .navigationTitle("Task Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingEdit = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditTaskView(item: item)
        }
    }
}
