//
//  ShoppingList.swift
//  Repascope
//
//  Created by Mickael on 29/04/2026.
//

import SwiftUI
import SwiftData

struct ShoppingListView: View {
    
    let date:Date
    
    @Environment(\.modelContext) private var modelContext
    
    // Calcule le début et la fin de la semaine
    private var startOfWeek: Date {
        CalendarViewModel.firstDayOfWeek(
            startWeekday: .saturday,
            from: date
        )!
    }
    
    @Query(sort: \ShoppingList.weekStart) private var shoppingLists:[ShoppingList]
    
    private var currentList: ShoppingList? {
        shoppingLists.first {
            CalendarViewModel.calendar.isDate($0.weekStart, inSameDayAs: startOfWeek)
        }
    }
    
    private var sortedList: [ShoppingItem] {
        (currentList?.items ?? []).sorted { !$0.isChecked && $1.isChecked }
    }
    
    @State private var isAddingItem: Bool = false
    @State private var newItemName: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var showEmptyListAlert: Bool = false
    
    
    init(date: Date) {
        self.date = date
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            
            header
            
            Group {
                shoppingListView
                
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
            Text("Liste de courses")
                .font(.system(size: 22))
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.vertical, 12)
            Spacer()
            Button {
                exportToNotes(items: currentList?.items ?? [])
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .padding(.trailing)
                    .font(.system(size: 18))
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(Color.white)
        .frame(height: 45)
        .background(Color.noon)
    }
    
    private var shoppingListView: some View {
        List {
            ForEach(shoppingCategory.allCases, id: \.self) { cat in
                Section(cat.rawValue) {
                    
                    let itemsToShow = sortedList
                        .filter{$0.category == cat}
                        .sorted{
                            if $0.isChecked != $1.isChecked {
                                return !$0.isChecked
                            } else {
                                return $0.name < $1.name
                            }
                        }
                    
                    ForEach(itemsToShow, id: \.self) { item in
                        ShoppingListItem(item: item, deleteAction: { delete(item: item) })
                            .listRowSeparator(.hidden)
                    }
                    
                    //TODO: Pouvoir ajouter des éléments dans les autres catégories
                }
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
        .safeAreaInset(edge: .top) {
            Color.clear
                .frame(height: 1)
        }
    }
    
    func startAddingItem() {
        if isAddingItem == false {
            if let currentList {
                removeJustAddedAspect(for: currentList.items)
            }
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
        let item = ShoppingItem(name: name)
        
        if let currentList {
            currentList.items.append(item)
        } else {
            let newList = ShoppingList(weekStart: startOfWeek, items: [item])
            modelContext.insert(newList)
        }
        
        do {
            try modelContext.save()
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
        } catch {
            print("SAVE ERROR:", error)
        }
    }

    func deleteAllItems() {
        currentList?.items.forEach { modelContext.delete($0) }
        
        do {
            try modelContext.save()
        } catch {
            print("SAVE ERROR:", error)
        }
    }
    
    func removeJustAddedAspect(for shoppingItems: [ShoppingItem]) {
        for item in shoppingItems {
            item.justAdded = false
        }
    }
    
    func exportToNotes(items: [ShoppingItem]) {
        let htmlItems = items.map { item in
            let checked = item.isChecked ? "true" : "false"
            return "<li data-checked='\(checked)'>\(item.name)</li>"  // ← apostrophes
        }.joined(separator: "\n")
        
        let html = "<ul class='checked'>\n\(htmlItems)\n</ul>"
        
        // Échapper les apostrophes éventuelles dans les noms d'articles
        //let safeName = "Liste de courses"
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
            .buttonStyle(.bordered)
            
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
            .tint(Color.noon)
        }
    }
    
    
}

#Preview {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, ShoppingItem.self, configurations: config)
    
    let previewDate = Date()
    let weekStart = CalendarViewModel.firstDayOfWeek(
        startWeekday: .saturday,
        from: previewDate
    )!
    
    let shoppingList = ShoppingList(weekStart: weekStart, items: [
        ShoppingItem(name: "Pâtes", quantity: 1, category: .food, justAdded: false),
        ShoppingItem(name: "Gel douche", quantity: 1, category: .other, justAdded: false),
        ShoppingItem(name: "Viande hachée", quantity: 1, category: .food, justAdded: true),
        ShoppingItem(name: "Brioche", quantity: 1, category: .breakfast, justAdded: false),
        ShoppingItem(name: "Biscuits", quantity: 1, category: .snackTime, justAdded: false)
    ])
    
    container.mainContext.insert(shoppingList)
    
    try? container.mainContext.save()
    
    return ShoppingListView(date: previewDate)
        .modelContainer(container)
}
