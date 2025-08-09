//
//  CalendarView.swift
//  Momentum
//
//  Created by jiaruh on 2/8/2025.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
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
    @Query private var items: [Item]

    let date: Date

    var filteredItems: [Item] {
        items.filter { item in
            if let dueDate = item.dueDate {
                return Calendar.current.isDate(dueDate, inSameDayAs: date)
            }
            return false
        }
    }

    var body: some View {
        VStack {
            if filteredItems.isEmpty {
                Text("No tasks for this day.")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List {
                    ForEach(filteredItems) { item in
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
    CalendarView()
        .modelContainer(for: Item.self, inMemory: true)
}
