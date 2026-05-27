//
//  ShoppingList.swift
//  Repascope
//
//  Created by Mickael on 29/04/2026.
//

import SwiftUI
import SwiftData

struct ShoppingListView: View {
    
    let date: Date
    let startOfWeek: Date
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var shoppingLists: [ShoppingList]
    private var currentList: ShoppingList? { shoppingLists.first }
    private var items: [ShoppingItem] { currentList?.items ?? [] }
    
    @State private var showEmptyListAlert: Bool = false
    
    init(date: Date) {
        self.date = date
        
        let start = CalendarViewModel.firstDayOfWeek(startWeekday: .saturday, from: date)!
        
        self.startOfWeek = start
        
        let end = CalendarViewModel.calendar.date(byAdding: .day, value: 1, to: start)!
        
        _shoppingLists = Query(
            filter: #Predicate<ShoppingList> { list in
                list.weekStart >= start && list.weekStart < end
            },
            sort: \.weekStart
        )
    }
    
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            header
            shoppingListView
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
                showEmptyListAlert = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 18))
                    .padding(.trailing, 10)
            }
            .buttonStyle(.plain)
            
            Button {
                //TODO: Share list
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
            .sorted {
                if $0.isChecked != $1.isChecked {
                    return !$0.isChecked
                } else {
                    return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }
            }
    }
    
    private func delete(item: ShoppingItem) {
        modelContext.delete(item)
        
        do {
            try modelContext.save()
        } catch {
            print("SAVE ERROR:", error)
        }
    }
    
    private func deleteAllItems() {
        
        let itemsToDelete = items
        
        for item in itemsToDelete {
            modelContext.delete(item)
        }
        
        do { try modelContext.save() } catch { print("SAVE ERROR:", error) }
    }
}

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
                .opacity(0.8)
            
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
        ShoppingItem(name: "Brioche", quantity: 1, category: .snack, justAdded: false),
        ShoppingItem(name: "Biscuits", quantity: 2, category: .snack, justAdded: true)
    ])
    
    container.mainContext.insert(shoppingList)
    
    try? container.mainContext.save()
    
    return ShoppingListView(date: previewDate)
        .modelContainer(container)
}
