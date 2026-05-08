//
//  ShoppingList.swift
//  Repascope
//
//  Created by Mickael on 29/04/2026.
//

import SwiftUI
import SwiftData

struct ShoppingList: View {
    
    let date:Date
    
    @Environment(\.modelContext) private var modelContext
    
    // Calcule le début et la fin du jour
    private var startOfDay: Date {
        Calendar.current.startOfDay(for: date)
    }
    private var endOfDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
    }
    
    @Query private var shoppingList:[ShoppingItem]
    
    private var sortedList: [ShoppingItem] {
        shoppingList.sorted { !$0.isChecked && $1.isChecked }
    }
    
    @State private var isAddingItem: Bool = false
    @State private var newItemName: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var showEmptyListAlert: Bool = false
    
    init(date:Date) {
        self.date = date
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        
        _shoppingList = Query(
            filter: #Predicate<ShoppingItem> { item in
                item.date >= start && item.date < end
            }
        )
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            
            HStack {
                Text("Liste de courses")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                Spacer()
                Button {
                    exportToNotes(items: shoppingList)
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .padding(.trailing)
                        .font(.system(size: 18))
                }
                .buttonStyle(.plain)

            }
            
            Divider()
            
            Group {
                List {
                    ForEach(sortedList, id: \.self) { item in
                        ShoppingListItem(item: item, deleteAction: { delete(item: item) })
                            .listRowSeparator(.hidden)
                    }
                    
                    if isAddingItem {
                        HStack {
                            Image(systemName: "circle")
                                .font(.system(size: 18))
                            TextField("Nouvel élément", text: $newItemName)
                                .focused($isInputFocused)
                                .onSubmit { confirmNewItem() }
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                
                let emptyAction = { showEmptyListAlert = true }
                let addAction = { startAddingItem() }

                ShoppingListButtons(
                    emptyListAction: emptyAction,
                    startAddingItemAction: addAction,
                    isAddingItem: isAddingItem
                )
                .frame(maxWidth: .infinity)
                .padding()
            }
            .background(Color.white)
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.pink.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.pink.opacity(0.3), lineWidth: 3)
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
    
    func startAddingItem() {
        if isAddingItem == false {
            newItemName = ""
            isAddingItem = true
            isInputFocused = true
        } else {
            // Action "Terminer"
            confirmNewItem()
            isAddingItem = false
        }
    }
    
    func confirmNewItem() {
        let name = newItemName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else {
            isAddingItem = false
            return
        }
        modelContext.insert(ShoppingItem(name: name, quantity: 1, date: date))
        
        do {
            try modelContext.save()
            print("SAVE OK")
        } catch {
            print("SAVE ERROR:", error)
        }
        
        newItemName = ""
        // reste en mode saisie pour enchaîner les ajouts
        isInputFocused = true
    }
    
    func delete(item: ShoppingItem) {
        modelContext.delete(item)
        
        do {
            try modelContext.save()
            print("SAVE OK")
        } catch {
            print("SAVE ERROR:", error)
        }
    }

    func deleteAllItems() {
        shoppingList.forEach { modelContext.delete($0) }
        
        do {
            try modelContext.save()
            print("SAVE OK")
        } catch {
            print("SAVE ERROR:", error)
        }
    }
    
    func exportToNotes(items: [ShoppingItem]) {
        let htmlItems = items.map { item in
            let checked = item.isChecked ? "true" : "false"
            return "<li data-checked='\(checked)'>\(item.name)</li>"  // ← apostrophes
        }.joined(separator: "\n")
        
        let html = "<ul class='checked'>\n\(htmlItems)\n</ul>"
        
        // Échapper les apostrophes éventuelles dans les noms d'articles
        let safeName = "Liste de courses"
        let safeHtml = html.replacingOccurrences(of: "\\", with: "\\\\")
                           .replacingOccurrences(of: "\"", with: "\\\"")
        
        let script = """
        tell application "Notes"
            activate
            set noteBody to "\(safeHtml)"
            make new note with properties {name:"Liste de courses", body:noteBody}
        end tell
        """
        
        var appleScriptError: NSDictionary?
        if let result = NSAppleScript(source: script)?.executeAndReturnError(&appleScriptError) {
            print("AppleScript OK:", result)
        } else if let err = appleScriptError {
            print("AppleScript ERROR:", err)
        }
    }
}

struct ShoppingListButtons: View {
    
    let emptyListAction: () -> Void
    let startAddingItemAction: () -> Void
    let isAddingItem: Bool
    
    var body: some View {
        HStack {
            Button(role: .destructive) {
                emptyListAction()
            } label: {
                Label("Vider la liste", systemImage: "trash")
            }
            
            Button(role: .none) {
                startAddingItemAction()
            } label: {
                if isAddingItem {
                    Label("Terminer", systemImage: "xmark")
                } else {
                    Label("Ajouter", systemImage: "plus")
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
        }
    }
    
    
}

#Preview {
    ShoppingList(date: Date())
}
