//
//  GuestListView.swift
//  Popote
//
//  Created by Mickael Thibouret on 29/05/2026.
//

import SwiftUI
import SwiftData

struct GuestListView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    let guests: [Guest]
    
    @State private var showDeleteGuestAlert = false
    @State private var newGuestTextField = ""
    @State private var newGuestColor: Color = Color.theme
    @State private var guestToDelete: Guest? = nil
    @State private var editingGuest: Guest?
    
    var body: some View {
        VStack {
            
            HStack(alignment: .lastTextBaseline) {
                
                Text("Convives")
                    .font(.system(size: 24, weight: .bold))
                
                Spacer()
                
                Button {
                    addGuestAction()
                } label: {
                    Label("Ajouter", systemImage: "plus")
                }
                .padding(.trailing)
                .buttonStyle(.borderless)
            }
            .foregroundStyle(Color.white)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(
                Color.noon
            )
            
            List {
                ForEach(guests) { guest in
                    GuestListLineView(
                        guest: guest,
                        deleteAction: {
                            guestToDelete = guest
                            showDeleteGuestAlert = true
                        },
                        isEditing: editingGuest == guest,
                        startEditing: {
                            editingGuest = guest
                        },
                        stopEditing: {
                            if let editedName = editingGuest?.name {
                                if editedName.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                                    editingGuest?.name = "Inconnu"
                                }
                            }
                            editingGuest = nil
                        })
                    .frame(height: 50)
                    .listRowSeparator(.hidden)
                    .draggable((GuestTransfer(persistentID: guest.persistentModelID)))
                }
            }
        }
        .alert("Supprimer \(guestToDelete?.name ?? "ce convive") ?", isPresented: $showDeleteGuestAlert) {
            Button(role: .destructive) {
                if let guestToDelete {
                    deleteGuest(guest: guestToDelete)
                }
            }
            
            Button(role: .cancel, action: {})
            
        }
    }
    
    func addGuestAction() {
        let newGuest = Guest(name: "Invité", colorHex: Color.theme.displayP3HexString)
        modelContext.insert(newGuest)
        do { try modelContext.save() } catch { print(error) }
        editingGuest = newGuest
    }
    
    func deleteGuest(guest: Guest) {
        modelContext.delete(guest)
        do { try modelContext.save() } catch { print("Erreur de suppression", error)}
        guestToDelete = nil
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
