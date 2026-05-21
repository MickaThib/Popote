//
//  ContentView.swift
//  Repascope
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
                    Text("Convives à venir")
                }
            }
        }
        .toolbarBackground(.hidden, for: .windowToolbar)
        .background(
//            LinearGradient(
//                colors: [
//                    .themeContrast,
//                    .theme
//                ],
//                startPoint: .bottom,
//                endPoint: .top
//            )
            Color.theme.opacity(0.2)
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Guest.self, inMemory: true)
}
