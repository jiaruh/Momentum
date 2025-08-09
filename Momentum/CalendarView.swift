//
//  CalendarView.swift
//  Momentum
//
//  Created by jiaruh on 2/8/2025.
//

import SwiftUI
import CoreData

struct CalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedDate = Date()

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    DatePicker(
                        "Select a date",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .padding()

                    TasksForDateView(date: selectedDate)
                }
                .navigationTitle("Calendar")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct TasksForDateView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var items: FetchedResults<Item>

    let date: Date

    init(date: Date) {
        self.date = date
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!

        _items = FetchRequest<Item>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.createdAt, ascending: true)],
            predicate: NSPredicate(format: "dueDate >= %@ AND dueDate < %@", startDate as NSDate, endDate as NSDate)
        )
    }

    var body: some View {
        VStack {
            if items.isEmpty {
                Text("No tasks for this day.")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List {
                    ForEach(items) { item in
                        TaskRow(item: item)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}

#Preview {
    CalendarView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
