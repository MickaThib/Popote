//
//  GuestsGroupsView.swift
//  Popote
//
//  Created by Mickael Thibouret on 29/05/2026.
//

import SwiftUI
import SwiftData

struct GuestsGroupsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    
    @Query private var guestGroups: [GuestsGroup]
    
    @State private var showDeleteAlert = false
    @State private var editingGroup: GuestsGroup? = nil
    @State private var groupToDelete: GuestsGroup? = nil
        
    let columns = [
        GridItem(.adaptive(minimum: 200, maximum: 230), spacing: 20)
    ]
    
    var body: some View {
        VStack {
            HStack(alignment: .lastTextBaseline) {
                
                Text("Groupes de convives")
                    .font(.system(size: 24, weight: .bold))
                    .lineLimit(1)
                
                Spacer()
                
                Button {
                    let newGuestsGroup = GuestsGroup(title: "Groupe")
                    modelContext.insert(newGuestsGroup)
                    editingGroup = newGuestsGroup
                    
                    do { try modelContext.save() } catch { print(error) }
                    
                } label: {
                    Label("Ajouter", systemImage: "plus")
                }
                .padding(.trailing)
                .buttonStyle(.borderless)
            }
            .foregroundStyle(Color.white)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background( appSettings.mainColor )
            .frame(minWidth: 370)
            
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(guestGroups) { group in
                        GuestGroupView(guestsGroup: group,
                                       deleteAction: {
                            groupToDelete = group
                            showDeleteAlert = true
                        },
                                       startEditingAction: {
                            editingGroup = group
                        },
                                       endEditingAction: {
                            if editingGroup == group {
                                editingGroup = nil
                            }
                        },
                                       isEditing: editingGroup == group)
                    }
                }
                .frame(minWidth: 320)
                .padding()
            }
        }
        .alert("Supprimer ce groupe ?", isPresented: $showDeleteAlert) {
            Button(role: .destructive) {
                if let groupToDelete {
                    deleteGroup(group: groupToDelete)
                }
                groupToDelete = nil
            }
            
            Button(role: .cancel) {
                groupToDelete = nil
            }
        }
    }
    
    private func deleteGroup(group: GuestsGroup) {
        modelContext.delete(group)
        do { try modelContext.save() } catch { print(error) }        
    }
}

#Preview {
    GuestsGroupsView()
}
