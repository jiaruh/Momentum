
//
//  ContentView.swift
//  Momentum
//
//  Created by jiaruh on 2/8/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
        }
    }
}

#Preview {
    ContentView()
}
