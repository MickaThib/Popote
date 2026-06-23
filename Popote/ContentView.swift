//
//  ContentView.swift
//  Popote
//
//  Created by Mickael on 29/04/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        if hasSeenOnboarding {
            VStack {
                TabView {
                    Tab("Planning", systemImage: "calendar") {
                        OrganizerView()
                    }
                    
                    Tab("Repas", systemImage: "fork.knife") {
                        MealsManager()
                    }
                    
                    Tab("Convives", systemImage: "person.2.fill") {
                        GuestsView()
                    }
                }
            }
            .toolbarBackground(.hidden, for: .windowToolbar)
            .background( appSettings.mainColor.opacity(0.1) )
        } else {
            WelcomeView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Guest.self, inMemory: true)
}
