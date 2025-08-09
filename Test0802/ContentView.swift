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
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    HStack {
                        TextField("Add a new task...", text: $newTask)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .padding(.leading)

                        Button(action: addItem) {
                            Image(systemName: "plus.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                        .padding(.trailing)
                        .disabled(newTask.isEmpty)
                    }
                    .padding()

                    List {
                        ForEach(items) { item in
                            HStack {
                                Button(action: {
                                    item.isCompleted.toggle()
                                    saveContext()
                                }) {
                                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(item.isCompleted ? .green : .primary)
                                }
                                .buttonStyle(PlainButtonStyle())

                                Text(item.task ?? "Untitled")
                                    .strikethrough(item.isCompleted, color: .primary)
                                    .foregroundColor(item.isCompleted ? .secondary : .primary)
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                            .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteItems)
                        .listRowBackground(Color.clear)
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

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}