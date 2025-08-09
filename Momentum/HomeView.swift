//
//  ContentView.swift
//  Momentum
//
//  Created by jiaruh on 2/8/2025.
//

import SwiftUI
import SwiftData

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
                dueDate: dueDate,
                priority: priority.rawValue
            )
            modelContext.insert(newItem)
            
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct EditTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Bindable var item: Item
    
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
                
                Section {
                    Button("Save Changes") {
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