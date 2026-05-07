//
//  IngredientList.swift
//  Repascope
//
//  Created by Mickael on 04/05/2026.
//

import SwiftUI
import SwiftData

struct IngredientListView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Ingredient.name) private var ingredients: [Ingredient]
    
    @State var showDeleteAlert:Bool = false
    @State private var ingredientToDelete:Ingredient?
    
    @State var showAddIngredientSheet:Bool = false
    @State var ingredientToAdd: String = ""
    
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack(alignment: .lastTextBaseline) {
                
                Text("Ingrédients")
                    .font(.largeTitle)
                    .padding(.top)
                    .padding(.horizontal)
                
                Spacer()
                
                Button {
                    showAddIngredientSheet = true
                } label: {
                    Label("Ajouter", systemImage: "plus")
                }
                .padding(.trailing)
                .buttonStyle(.borderless)
            }
            .padding(.horizontal)
            .padding(.top)
            
            //TODO: Recherche
            TextField("Rechercher", text: .constant(""))
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .padding(.vertical)
            
            List(ingredients, id: \.id) { ingredient in
                CustomLabel(
                    title: ingredient.name,
                    type: .ingredient,
                    isSelected: false,
                    newTitleAction: { newName in
                        ingredient.name = newName
                        try? modelContext.save()
                    },
                    deleteAction: {deleteIngredient(ingredient: ingredient)}
                )
                .listRowSeparator(.hidden)
                .frame(height: 25)
                .draggable(IngredientTransfer(persistentID: ingredient.persistentModelID))
            }
            .padding(.top, 0)
        }
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
        .sheet(isPresented: $showAddIngredientSheet, onDismiss: {
            ingredientToAdd = ""
        }) {
            VStack(spacing: 16) {
                Text("Ajouter un ingrédient")
                    .font(.headline)
                TextField("Nom de l'ingrédient", text: $ingredientToAdd)
                    .onSubmit {
                        addIngredient(name: ingredientToAdd)
                    }
                    .frame(width: 300)
                HStack {
                    Button("Annuler", role: .cancel) {
                        ingredientToAdd = ""
                        showAddIngredientSheet = false
                    }
                    Button("Ajouter") {
                        addIngredient(name: ingredientToAdd)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(ingredientToAdd.isEmpty)
                }
            }
            .padding()
        }
    }
    
    func addIngredient(name: String) {
        modelContext.insert(Ingredient(name: name))
        try? modelContext.save()
        ingredientToAdd = ""
        showAddIngredientSheet = false
        
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
