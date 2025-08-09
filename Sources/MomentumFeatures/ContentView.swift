import SwiftUI
import MomentumAuthentication

public struct ContentView: View {
    @StateObject private var authService = AuthenticationService()

    public init() {}

    public var body: some View {
        Group {
            if authService.isAuthenticated {
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
                    
                    StatsView()
                        .tabItem {
                            Image(systemName: "chart.bar.fill")
                            Text("Stats")
                        }
                }
            } else {
                VStack {
                    Text("Locked")
                        .font(.largeTitle)
                    Button("Unlock with Face ID") {
                        authService.authenticate()
                    }
                }
            }
        }
        .onAppear {
            authService.authenticate()
        }
    }
}