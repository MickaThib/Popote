//
//  CategoryTextField.swift
//  Popote
//
//  Created by Mickael on 12/06/2026.
//

import SwiftUI
import SwiftData

struct CategoryTextField: View {
    
    @Environment(\.modelContext) private var modelContext
    
    let category: ShoppingCategory
    let startOfWeek: Date
    let currentList: ShoppingList?
    
    @State private var newItemName: String = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        
        HStack {
            Image(systemName: "circle")
                .font(.system(size: 18))
            
            TextField("", text: $newItemName)
                .focused($isInputFocused)
                .onSubmit { confirmNewItem(keepFocus: true) }
                .onChange(of: isInputFocused) { _, isFocused in
                    confirmNewItem(keepFocus: false)
                }
        }
    }
    
    private func confirmNewItem(keepFocus: Bool = true) {
        
        let name = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        
        let item = ShoppingItem(name: name, category: category)
        
        if let currentList {
            currentList.clearJustAddedFlags()
            currentList.items.append(item)
        } else {
            let newList = ShoppingList(weekStart: startOfWeek, items: [item])
            modelContext.insert(newList)
        }
        
        do { try modelContext.save() } catch { print("SAVE ERROR:", error) }
        
        newItemName = ""
        
        if keepFocus {
            DispatchQueue.main.async {
                isInputFocused = true
            }
        }
    }
}
