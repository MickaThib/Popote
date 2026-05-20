//
//  MealsManager.swift
//  Repascope
//
//  Created by Mickael on 02/05/2026.
//

import SwiftUI
import SwiftData

struct MealsManager: View {
    
    // Ne sert que pour les données test -> a supprimer ensuite
    @Environment(\.modelContext) private var modelContext
    // Ne sert que pour les données test -> a supprimer ensuite
    @State var selectedMeal: MealItem? = nil
    @State var isEditingNewMeal: Bool = false
    
    var body: some View {
        HSplitView {
            
            MealListView(selectedMeal: $selectedMeal, addMeal: {
                let newMeal = MealItem(title: "Nouveau plat", photo: nil)
                modelContext.insert(newMeal)
                try? modelContext.save()
                selectedMeal = newMeal
                Task { @MainActor in
                    isEditingNewMeal = true  // déclenché après que la vue est montée
                }
            })
                .frame(width: 300)
                .padding(20)
            
            if let meal = selectedMeal {
                EditMealView(meal: meal, startEditing: $isEditingNewMeal)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                //TODO: a terminer
                Text("Aucun repas sélectionné")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            IngredientListView()
                .frame(width: 300)
                .padding(20)
            
        }
        .frame(maxWidth: .infinity)
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Button {
                    //TODO: Settings
                } label: {
                    Label("Réglages", systemImage: "gear")
                        .labelStyle(.iconOnly)
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Ingredient.self, MealItem.self, configurations: config)
    
    let ingredients = [
        Ingredient(name: "Carotte"),
        Ingredient(name: "Pommes de terre"),
        Ingredient(name: "Pain de mie"),
        Ingredient(name: "Avocats")
    ]
    
    let meals = [
        MealItem(title: "Raclette", photo: nil, ingredients: []),
        MealItem(title: "Hamburger maison", photo: nil, ingredients: []),
        MealItem(title: "Hot dogs", photo: nil, ingredients: []),
        MealItem(title: "Poisson pané", photo: nil, ingredients: []),
        MealItem(title: "Quiche lorraine", photo: nil, ingredients: []),
        MealItem(title: "Lasagnes", photo: nil, ingredients: [])
    ]
    
    for ingredient in ingredients { container.mainContext.insert(ingredient) }
    for meal in meals { container.mainContext.insert(meal) }
    
    return MealsManager()
        .modelContainer(container)
}
