//
//  GuestsView.swift
//  Popote
//
//  Created by Mickael Thibouret on 29/05/2026.
//

import SwiftUI
import SwiftData

struct GuestsView: View {
    
    @Query(sort: \Guest.name) var guests: [Guest]
    
    var body: some View {
        
        HStack(spacing: 20) {
            GuestListView(guests: guests)
                .frame(width: 300)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: Color.theme.opacity(0.3),radius: 6, x: 5, y: 5)
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 0))
            
            GuestsGroupsView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: Color.theme.opacity(0.3),radius: 6, x: 5, y: 5)
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 20))
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Guest.self, GuestsGroup.self,
            configurations: config
        )

        let guests = [
            Guest(name: "Mickael", colorHex: "4076f5"),
            Guest(name: "Marie", colorHex: "f540a7"),
            Guest(name: "Soline", colorHex: "f5bf40"),
            Guest(name: "Erwann", colorHex: "5a6282"),
            Guest(name: "Margaux", colorHex: "44b393")
        ]

        for guest in guests {
            container.mainContext.insert(guest)
        }

        try container.mainContext.save()

        return GuestsView()
            .modelContainer(container)

    } catch {
        return Text("Erreur preview : \(error.localizedDescription)")
    }
}
