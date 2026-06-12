//
//  ShoppingListContentView.swift
//  Popote
//
//  Created by Mickael Thibouret on 12/06/2026.
//
// Vue de la liste d'items, utilisée par ShoppingListFullView (planning global) et ShoppingListPanelView (liste détachée)

import SwiftUI
import SwiftData

struct ShoppingListContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    let startOfWeek: Date
    let currentList: ShoppingList?
    private var items: [ShoppingItem] { currentList?.items ?? [] }
    
    var body: some View {
        List {
            ForEach(ShoppingCategory.allCases, id: \.self) { cat in
                Section(cat.rawValue) {
                    
                    ForEach(items(for: cat), id: \.self) { item in
                        ShoppingListItem(item: item, deleteAction: { delete(item: item) })
                            .listRowSeparator(.hidden)
                    }
                    
                    CategoryTextField(category: cat, startOfWeek: startOfWeek, currentList: currentList)
                        .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .safeAreaInset(edge: .top) {
            Color.clear
                .frame(height: 1)
        }
    }
    
    private func items(for category: ShoppingCategory) -> [ShoppingItem] {
        items
            .filter { $0.category == category }
//          Décommenter pour activer le tri par état coché/non coché
//            .sorted {
//                if $0.isChecked != $1.isChecked {
//                    return !$0.isChecked
//                } else {
//                    return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
//                }
//            }
    }
    
    private func delete(item: ShoppingItem) {
        modelContext.delete(item)
        
        do {
            try modelContext.save()
        } catch {
            print("SAVE ERROR:", error)
        }
    }
}

#Preview {
    ShoppingListContentView(startOfWeek: Date(), currentList: nil)
}
