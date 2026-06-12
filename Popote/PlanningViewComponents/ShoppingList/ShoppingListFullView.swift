//
//  ShoppingListFullView.swift
//  Popote
//
//  Created by Mickael on 12/06/2026.
//
// Vue complète présente dans la vue planning globale (header + liste d'items)

import SwiftUI
import SwiftData

struct ShoppingListFullView: View {
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var shoppingPanelController: ShoppingListPanelController
    
    let startOfWeek: Date
    let currentList: ShoppingList?
    
    @State private var showEmptyListAlert = false
    @State private var shareErrorMessage: String?
    @State private var showExportSuccess = false
    
    private let reminderExporter = ShoppingReminderExporter()
    
    private var items: [ShoppingItem] {
        currentList?.items ?? []
    }
    
    private var isShareMenuActive: Bool {
        guard let currentList else { return false }
        return !currentList.items.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            
            ShoppingListContentView(
                startOfWeek: startOfWeek,
                currentList: currentList
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.top)
        .alert("Vider la liste ?", isPresented: $showEmptyListAlert) {
            Button("Vider la liste", role: .destructive) {
                deleteAllItems()
            }
            Button("Annuler", role: .cancel) {}
        }
    }
    
    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Mes courses")
                .font(.system(size: 22))
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.vertical, 12)
            
            Spacer()
            
            Button {
                shoppingPanelController.show(weekToDisplay: startOfWeek)
            } label: {
                Image(systemName: "arrow.down.backward.and.arrow.up.forward.rectangle")
                    .font(.system(size: 18))
                    .padding(.trailing, 7)
            }
            .buttonStyle(.plain)
            
            Button {
                showEmptyListAlert = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 18))
                    .padding(.trailing, 7)
            }
            .buttonStyle(.plain)
            
            Menu {
                Button {
                    Task {
                        await exportToReminders()
                    }
                } label: {
                    Label("Exporter vers Rappels", systemImage: "checklist")
                }
                
                ShareLink(
                    item: shoppingListText,
                    subject: Text("Liste de courses Popote"),
                    message: Text("Voici la liste de courses.")
                ) {
                    Label("Partager en texte", systemImage: "text.alignleft")
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .padding(.trailing)
                    .font(.system(size: 18))
            }
            .buttonStyle(.plain)
            .disabled(!isShareMenuActive)
            .alert("Erreur", isPresented: .constant(shareErrorMessage != nil)) {
                Button("OK") {
                    shareErrorMessage = nil
                }
            } message: {
                Text(shareErrorMessage ?? "")
            }
            .alert("Export terminé", isPresented: $showExportSuccess) {
                Button("OK") {}
            } message: {
                Text("La liste de courses a été exportée dans Rappels.")
            }
        }
        .foregroundStyle(Color.white)
        .frame(height: 45)
        .background(Color.noon)
    }
    
    private func deleteAllItems() {
        for item in items {
            modelContext.delete(item)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("SAVE ERROR:", error)
        }
    }
    
    private func exportToReminders() async {
        do {
            let title = "Courses Popote - \(Date().formatted(.dateTime.day().month().year()))"
            
            try await reminderExporter.export(
                listTitle: title,
                items: reminderExportItems
            )
            
            showExportSuccess = true
        } catch {
            shareErrorMessage = error.localizedDescription
        }
    }
    
    private var reminderExportItems: [ShoppingReminderExportItem] {
        guard let currentList else { return [] }
        
        return currentList.items
            .sorted {
                $0.name.localizedCompare($1.name) == .orderedAscending
            }
            .map {
                ShoppingReminderExportItem(
                    name: $0.name,
                    isCompleted: $0.isChecked
                )
            }
    }
    
    private var shoppingListText: String {
        guard let currentList else {
            return "La liste de courses est vide."
        }
        
        let sortedItems = currentList.items.sorted {
            $0.name.localizedCompare($1.name) == .orderedAscending
        }
        
        var list = "Liste de courses du \(Date().formatted(.dateTime.day().month().year()))\n\n"
        
        for category in ShoppingCategory.allCases {
            list.append("\(category.rawValue.uppercased()) :\n\n")
            
            for item in sortedItems where item.category == category {
                list.append("• \(item.name)\n")
            }
            
            list.append("\n")
        }
        
        return list
    }
}

struct ShoppingReminderExportItem {
    let name: String
    let isCompleted: Bool
}

#Preview {
    ShoppingListFullView(startOfWeek: Date(), currentList: nil)
}
