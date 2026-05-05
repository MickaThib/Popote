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
    
    var body: some View {
        HSplitView {
            
            MealListView(selectedMeal: $selectedMeal)
                .frame(width: 270)
            
            if let meal = selectedMeal {
                EditMealView(meal: meal)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                //TODO: a terminer
                Text("Aucun repas sélectionné")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            IngredientListView()
                .frame(width: 300)
            
        }
        .frame(maxWidth: .infinity)
        .toolbar {
            Button("Données de test") {
                addDataTest()
            }
            Button("Delete all Meals") {
                try? modelContext.delete(model: MealItem.self)
            }
        }
    }
    
    
    func addDataTest() {
        let mealsDataTest = [
            MealItem(title: "Raclette", photo: nil, ingredients: []),
            MealItem(title: "Hamburger maison", photo: nil, ingredients: []),
            MealItem(title: "Hot dogs", photo: nil, ingredients: []),
            MealItem(title: "Poisson pané", photo: nil, ingredients: []),
            MealItem(title: "Quiche lorraine", photo: nil, ingredients: []),
            MealItem(title: "Lasagnes", photo: nil, ingredients: [])
        ]
        
        for meal in mealsDataTest {
            modelContext.insert(meal)
            try? modelContext.save()
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
