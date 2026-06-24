//
//  IngredientList.swift
//  Popote
//
//  Created by Mickael on 04/05/2026.
//

import SwiftUI
import SwiftData

struct IngredientListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    
    @Query(sort: \Ingredient.name) private var ingredients: [Ingredient]
    
    @State private var showDeleteAlert:Bool = false
    @State private var ingredientToDelete:Ingredient?
    
    @State var showAddIngredientSheet:Bool = false
    
    @State var searchText: String = ""
    var filteredIngredients: [Ingredient] {
        if searchText.isEmpty {
            ingredients
        } else {
            ingredients.filter {
                $0.name.localizedStandardContains(searchText)
            }
        }
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack(alignment: .lastTextBaseline) {
                
                Text("Ingrédients")
                    .font(.system(size: 24, weight: .bold))
                
                Spacer()
                
                Button {
                    showAddIngredientSheet = true
                } label: {
                    Label("Ajouter", systemImage: "plus")
                }
                .padding(.trailing)
                .buttonStyle(.borderless)
            }
            .foregroundStyle(.white)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background( appSettings.secondaryColor )
            
            //MARK: Recherche
            TextField("Rechercher", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 1)
                .overlay(alignment: .trailing) {
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 15)
                        .padding(.trailing, 25)
                    }
                }
            
            List(filteredIngredients, id: \.id) { ingredient in
                IngredientCustomLabel(
                    title: ingredient.name,
                    newTitleAction: { newName in
                        ingredient.name = newName
                        try? modelContext.save()
                    },
                    deleteAction: {deleteIngredient(ingredient: ingredient)}
                )
                .listRowSeparator(.visible)
                .draggable(IngredientTransfer(persistentID: ingredient.persistentModelID))
            }
            .padding(.top, 0)
            .padding(.bottom, 20)
        }
        .background(
            Color.white
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 10)
        )
        .alert("Supprimer \(ingredientToDelete?.name ?? "cet ingrédient") ?", isPresented: $showDeleteAlert) {
            Button("Annuler", role: .cancel) {
                ingredientToDelete = nil
            }
            Button("Supprimer", role: .destructive) {
                if let ingredient = ingredientToDelete {
                    modelContext.delete(ingredient)
                    try? modelContext.save()
                    ingredientToDelete = nil
                }
            }
        }
        .sheet(isPresented: $showAddIngredientSheet) {

            IngredientAddSheet(
                existingIngredients: ingredients
            ) { name in
                addIngredient(name: name)
            } onInsertExisting: { _ in }
        }
    }
    
    func addIngredient(name: String) {
        modelContext.insert(Ingredient(name: name))
        do {
            try modelContext.save()
        } catch {
            print(error)
        }
    }
    
    func deleteIngredient(ingredient:Ingredient) {
        ingredientToDelete = ingredient
        showDeleteAlert = true
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Ingredient.self, configurations: config)
    
    let ingredients = [
        Ingredient(name: "Carotte"),
        Ingredient(name: "Pommes de terre"),
        Ingredient(name: "Pain de mie"),
        Ingredient(name: "Avocats")
    ]
    
    for ingredient in ingredients { container.mainContext.insert(ingredient) }
    
    return IngredientListView()
        .modelContainer(container)
}
