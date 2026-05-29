//
//  GuestListView.swift
//  Repascope
//
//  Created by Mickael Thibouret on 29/05/2026.
//

import SwiftUI

struct GuestListView: View {
    
    let guests: [Guest]
    
    var body: some View {
        VStack {
            
            Button {
                //
            } label: {
                Label("Ajouter", systemImage: "plus")
            }
            .buttonStyle(.plain)
            
            List {
                ForEach(guests) { guest in
                    GuestListLineView(guest: guest, editAction: {
                        //TODO: Edit guest
                    })
                    .frame(height: 50)
                }
            }
        }
    }
}

#Preview {
    GuestListView(guests: [
        Guest(name: "Mickael", colorHex: "4076f5"),
        Guest(name: "Marie", colorHex: "f540a7"),
        Guest(name: "Soline", colorHex: "f5bf40"),
        Guest(name: "Erwann", colorHex: "5a6282"),
        Guest(name: "Margaux", colorHex: "44b393"),
    ])
}
