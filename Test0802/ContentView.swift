//
//  ContentView.swift
//  Test0802
//
//  Created by jiaruh on 2/8/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.createdAt, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @State private var newTask: String = ""

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter a new task", text: $newTask)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)

                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus.circle.fill")
                            .font(.title2)
                    }
                    .padding(.trailing)
                    .disabled(newTask.isEmpty)
                }
                .padding(.top)

                List {
                    ForEach(items) { item in
                        HStack {
                            Toggle(isOn: Binding(
                                get: { item.isCompleted },
                                set: {
                                    item.isCompleted = $0
                                    saveContext()
                                }
                            )) {
                                Text(item.task ?? "Untitled")
                                    .strikethrough(item.isCompleted, color: .primary)
                                    .foregroundColor(item.isCompleted ? .secondary : .primary)
                            }
                            .toggleStyle(CheckboxToggleStyle())
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .navigationTitle("To-Do List")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.createdAt = Date()
            newItem.task = newTask
            newItem.isCompleted = false
            
            saveContext()
            
            // Clear the text field
            newTask = ""
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

// A custom toggle style to look more like a checkbox
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .font(.title2)
                configuration.label
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
