import SwiftUI
import SwiftData
import PhotosUI
import UIKit
import MomentumCore
import MomentumUI

/// Sorting criteria for tasks.
enum TaskSortOption: String, CaseIterable, Identifiable {
    case creationDateNewest = "Creation Date (Newest)"
    case creationDateOldest = "Creation Date (Oldest)"
    case dueDateSoonest = "Due Date (Soonest)"
    case dueDateLatest = "Due Date (Latest)"
    case priorityHighToLow = "Priority (High to Low)"
    case priorityLowToHigh = "Priority (Low to High)"
    case alphabeticalAtoZ = "Alphabetical (A-Z)"
    case alphabeticalZtoA = "Alphabetical (Z-A)"
    
    var id: String { self.rawValue }
    
    /// Provides a localized description for the sort option.
    var localizedDescription: String {
        self.rawValue
    }
}



public struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item] // Sorting will be handled in filteredItems

    @State private var showingAddTaskView = false
    @State private var searchText = ""
    @State private var selectedSortOption: TaskSortOption = .creationDateNewest // Default sort
    @State private var selectedStatusFilter: TaskStatusFilter = .all // Default status filter
    @State private var selectedPriorityFilter: TaskPriorityFilter = .all // Default priority filter

    public init() {}

    private var filteredItems: [Item] {
        // 1. Apply search filter
        let searchFilteredItems: [Item]
        if searchText.isEmpty {
            searchFilteredItems = items
        } else {
            searchFilteredItems = items.filter { item in
                item.task.localizedCaseInsensitiveContains(searchText) ||
                (item.detailsText?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // 2. Apply status filter
        let statusFilteredItems: [Item]
        switch selectedStatusFilter {
        case .all:
            statusFilteredItems = searchFilteredItems
        case .active:
            statusFilteredItems = searchFilteredItems.filter { !$0.isCompleted }
        case .completed:
            statusFilteredItems = searchFilteredItems.filter { $0.isCompleted }
        }
        
        // 3. Apply priority filter
        let priorityFilteredItems: [Item]
        switch selectedPriorityFilter {
        case .all:
            priorityFilteredItems = statusFilteredItems
        case .low, .normal, .high:
            priorityFilteredItems = statusFilteredItems.filter { item in
                item.priority == selectedPriorityFilter.rawValue
            }
        }
        
        // 4. Apply sorting
        let sortedItems = sortItems(priorityFilteredItems, by: selectedSortOption)
        
        return sortedItems
    }
    
    /// Sorts an array of items based on the specified sort option.
    /// - Parameters:
    ///   - items: The array of items to sort.
    ///   - option: The sorting option to apply.
    /// - Returns: A new array containing the sorted items.
    private func sortItems(_ items: [Item], by option: TaskSortOption) -> [Item] {
        switch option {
        case .creationDateNewest:
            return items.sorted { $0.createdAt > $1.createdAt }
        case .creationDateOldest:
            return items.sorted { $0.createdAt < $1.createdAt }
        case .dueDateSoonest:
            // Tasks without due dates go to the end
            return items.sorted { item1, item2 in
                guard let date1 = item1.dueDate else { return false }
                guard let date2 = item2.dueDate else { return true }
                return date1 < date2
            }
        case .dueDateLatest:
            // Tasks without due dates go to the end
            return items.sorted { item1, item2 in
                guard let date1 = item1.dueDate else { return false }
                guard let date2 = item2.dueDate else { return true }
                return date1 > date2
            }
        case .priorityHighToLow:
            // Define priority order
            let priorityOrder: [String: Int] = [
                TaskPriority.high.rawValue: 3,
                TaskPriority.normal.rawValue: 2,
                TaskPriority.low.rawValue: 1
            ]
            // Tasks without priority go to the end
            return items.sorted { item1, item2 in
                let priority1 = priorityOrder[item1.priority ?? ""] ?? 0
                let priority2 = priorityOrder[item2.priority ?? ""] ?? 0
                return priority1 > priority2
            }
        case .priorityLowToHigh:
            // Define priority order
            let priorityOrder: [String: Int] = [
                TaskPriority.high.rawValue: 3,
                TaskPriority.normal.rawValue: 2,
                TaskPriority.low.rawValue: 1
            ]
            // Tasks without priority go to the end
            return items.sorted { item1, item2 in
                let priority1 = priorityOrder[item1.priority ?? ""] ?? 0
                let priority2 = priorityOrder[item2.priority ?? ""] ?? 0
                return priority1 < priority2
            }
        case .alphabeticalAtoZ:
            return items.sorted { $0.task.localizedCaseInsensitiveCompare($1.task) == .orderedAscending }
        case .alphabeticalZtoA:
            return items.sorted { $0.task.localizedCaseInsensitiveCompare($1.task) == .orderedDescending }
        }
    }

    public var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    TextField("Search tasks...", text: $searchText)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                    
                    // Filter menus
                    FilterMenuView(
                        selectedStatusFilter: $selectedStatusFilter,
                        selectedPriorityFilter: $selectedPriorityFilter
                    )
                    .padding(.bottom, 8)

                    List {
                        ForEach(filteredItems) { item in
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
                        Menu {
                            Picker("Sort By", selection: $selectedSortOption) {
                                ForEach(TaskSortOption.allCases) { option in
                                    Text(option.localizedDescription).tag(option)
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                    }
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