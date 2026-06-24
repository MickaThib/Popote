//
//  ShoppingItem.swift
//  Popote
//
//  Created by Mickael on 29/04/2026.
//
// Un élément des listes de courses

import SwiftUI
import SwiftData

struct ShoppingListItem: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    
    let item: ShoppingItem
    var deleteAction: (() -> Void)?
    let isEditing: Bool
    var startEditing: () -> Void
    var endEditing: () -> Void
    
    @State var showDeleteAlert = false
    @FocusState private var titleFieldFocused: Bool
    
    
    var body: some View {
        HStack {
            Image(systemName: item.isChecked ? "inset.filled.circle" : "circle")
                .font(.system(size: 18))
            if isEditing {
                TextField("", text: Binding(
                    get: {
                        item.name
                    }, set: { newValue in
                        item.name = newValue
                    })
                )
                .focused($titleFieldFocused)
                .onAppear {
                    if isEditing {
                        DispatchQueue.main.async {
                            titleFieldFocused = true
                        }
                    }
                }
                .onChange(of: isEditing, { _, newValue in
                    if newValue {
                        DispatchQueue.main.async {
                            titleFieldFocused = true
                        }
                    } else {
                        titleFieldFocused = false
                    }
                })
                .onChange(of: titleFieldFocused, { _, newValue in
                    if newValue == false {
                        endEditing()
                    }
                })
                .onSubmit {
                    do { try modelContext.save() } catch { print(error) }
                    endEditing()
                }
            } else {
                Text(item.name)
                    .fontWeight(.bold)
                    .onTapGesture {
                        startEditing()
                    }
            }
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
        .foregroundStyle(item.justAdded ? appSettings.secondaryColor : appSettings.mainColorContrast)
        .opacity(item.isChecked ? 0.5 : 1)
        .onTapGesture {
            item.isChecked.toggle()
            item.shoppingList?.clearJustAddedFlags()
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
    ShoppingListItem(item: item, isEditing: false, startEditing: {}, endEditing: {})
        .modelContainer(container)
}
