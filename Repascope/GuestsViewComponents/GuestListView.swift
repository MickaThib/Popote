//
//  GuestListView.swift
//  Repascope
//
//  Created by Mickael Thibouret on 29/05/2026.
//

import SwiftUI
import SwiftData

struct GuestListView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    let guests: [Guest]
    
    @State private var showAddGuestSheet = false
    @State private var showDeleteGuestAlert = false
    @State private var newGuestTextField = ""
    @State private var newGuestColor: Color = Color.theme
    @State private var guestToDelete: Guest? = nil
    
    var body: some View {
        VStack {
            
            HStack(alignment: .lastTextBaseline) {
                
                Text("Convives")
                    .font(.system(size: 24, weight: .bold))
                
                Spacer()
                
                Button {
                    showAddGuestSheet = true
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
                Color.theme
            )
            
            List {
                ForEach(guests) { guest in
                    GuestListLineView(guest: guest, editAction: {
                        //TODO: Edit guest
                    }, deleteAction: {
                        guestToDelete = guest
                        showDeleteGuestAlert = true
                    })
                    .frame(height: 50)
                    .listRowSeparator(.hidden)
                }
            }
        }
        .sheet(isPresented: $showAddGuestSheet) {
            addGuestSheetContent
        }
        .alert("Supprimer ce convive ?", isPresented: $showDeleteGuestAlert) {
            Button(role: .cancel) {
                showDeleteGuestAlert = false
            }
            Button(role: .destructive) {
                if let guestToDelete {
                    deleteGuest(guest: guestToDelete)
                }
            }
        }
    }
    
    private var addGuestSheetContent: some View {
        VStack {
            
            Text("Ajouter un convive")
                .font(.title2)
                .fontWeight(.semibold)
            
            TextField("Nom", text: $newGuestTextField)
                .onSubmit {
                    addNewGuest(name: newGuestTextField, color: newGuestColor)
                }
            
            ColorPicker(selection: $newGuestColor) {
                Label("Couleur", systemImage: "paintpalette")
            }
            
            HStack {
                Spacer()
                Button(role: .cancel) {
                    showAddGuestSheet = false
                    newGuestTextField = ""
                    newGuestColor = Color.theme
                }
                Button(role: .confirm) {
                    addNewGuest(name: newGuestTextField, color: newGuestColor)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
    
    func addNewGuest(name: String, color: Color) {
        let guestName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let colorHex = color.hexString
        let newGuest = Guest(name: guestName, colorHex: colorHex)
        
        modelContext.insert(newGuest)
        do { try modelContext.save() } catch { print("Erreur de sauvegarde new guest", error)}
        
        showAddGuestSheet = false
    }
    
    func deleteGuest(guest: Guest) {
        modelContext.delete(guest)
        do { try modelContext.save() } catch { print("Erreur de suppression", error)}
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
