//
//  ShoppingItem.swift
//  Repascope
//
//  Created by Mickael on 29/04/2026.
//

import SwiftUI
import SwiftData

struct ShoppingListItem: View {
    
    @Environment(\.modelContext) private var modelContext
    
    let item: ShoppingItem
    var deleteAction: (() -> Void)?
    @State var showDeleteAlert = false
    
    var body: some View {
        HStack {
            Image(systemName: item.isChecked ? "inset.filled.circle" : "circle")
                .font(.system(size: 18))
            Text(item.name)
                .fontWeight(.bold)
            if item.quantity != 1 {
                Text("x \(item.quantity)")
            }
            
            Spacer()
            
            Button {
                item.quantity += 1
                do {
                    try modelContext.save()
                } catch {
                    print("SAVE ERROR:", error)
                }
            } label: { Image(systemName: "plus.circle") }
                .buttonStyle(.plain)
            Button {
                if item.quantity > 1 {
                    item.quantity -= 1
                    do {
                        try modelContext.save()
                    } catch {
                        print("SAVE ERROR:", error)
                    }
                } else {
                    showDeleteAlert = true
                }
            } label: { Image(systemName: "minus.circle") }
                .buttonStyle(.plain)
            
        }
        .foregroundStyle(Color.themeContrast)
        .opacity(item.isChecked ? 0.5 : 1)
        .onTapGesture {
            item.isChecked.toggle()
            do {
                try modelContext.save()
            } catch {
                print("SAVE ERROR:", error)
            }
        }
        .alert("Supprimer \(item.name) ?", isPresented: $showDeleteAlert) {
            Button("Supprimer", role: .destructive) { deleteAction?() }
            Button("Annuler", role: .cancel) {}
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingItem.self, configurations: config)
    let item = ShoppingItem(name: "Concombre", quantity: 1)
    ShoppingListItem(item: item, deleteAction: {})
        .modelContainer(container)
}
