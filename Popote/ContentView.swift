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
    
    var body: some View {
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
        .background(
//            LinearGradient(
//                colors: [
//                    .theme.opacity(0.2),
//                    .theme.opacity(0.1)
//                ],
//                startPoint: .bottom,
//                endPoint: .top
//            )
            Color.theme.opacity(0.1)
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Guest.self, inMemory: true)
}
