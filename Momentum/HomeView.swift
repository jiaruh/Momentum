//
//  ContentView.swift
//  Momentum
//
//  Created by jiaruh on 2/8/2025.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.createdAt, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @State private var showingAddTaskView = false

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
                        .environment(\.managedObjectContext, self.viewContext)
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
            offsets.map { items[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct TaskRow: View {
    @ObservedObject var item: Item
    @State private var showingEditTaskView = false
    
    var body: some View {
        HStack {
            Button(action: {
                item.isCompleted.toggle()
                saveContext()
            }) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? .green : .primary)
            }
            .buttonStyle(PlainButtonStyle())

            VStack(alignment: .leading) {
                Text(item.task ?? "Untitled")
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
    
    private func saveContext() {
        do {
            try item.managedObjectContext?.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct AddTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
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
            let newItem = Item(context: viewContext)
            newItem.createdAt = Date()
            newItem.task = task
            newItem.isCompleted = false
            newItem.priority = priority.rawValue
            newItem.dueDate = dueDate
            
            saveContext()
            
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct EditTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var item: Item
    
    @State private var task: String
    @State private var priority: AddTaskView.Priority
    @State private var dueDate: Date

    init(item: Item) {
        self.item = item
        _task = State(initialValue: item.task ?? "")
        _priority = State(initialValue: AddTaskView.Priority(rawValue: item.priority ?? "Normal") ?? .normal)
        _dueDate = State(initialValue: item.dueDate ?? Date())
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task name", text: $task)
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(AddTaskView.Priority.allCases) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
                
                Section {
                    Button("Save Changes") {
                        saveChanges()
                    }
                    .disabled(task.isEmpty)
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func saveChanges() {
        withAnimation {
            item.task = task
            item.priority = priority.rawValue
            item.dueDate = dueDate
            item.editedAt = Date()
            
            saveContext()
            
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

#Preview {
    HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}