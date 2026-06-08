//
//  MealsManager.swift
//  Popote
//
//  Created by Mickael on 02/05/2026.
//

import SwiftUI
import SwiftData

struct MealsManager: View {
    
    @Environment(\.modelContext) private var modelContext

    @State var selectedMeal: MealItem? = nil
    @State var isEditingNewMeal: Bool = false
    
    var body: some View {
        HStack {
            
            MealListView(selectedMeal: $selectedMeal, addMeal: {
                let newMeal = MealItem(title: "Nouveau plat")
                modelContext.insert(newMeal)
                try? modelContext.save()
                selectedMeal = newMeal
                Task { @MainActor in
                    isEditingNewMeal = true  // déclenché après que la vue est montée
                }
            })        .shadow(color: Color.theme.opacity(0.3),radius: 6, x: 5, y: 5)

                .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 5))
                .frame(minWidth: 300, maxWidth: 350)
            
            if let meal = selectedMeal {
                EditMealView(meal: meal, startEditing: $isEditingNewMeal)
                    .shadow(color: Color.theme.opacity(0.3),radius: 6, x: 5, y: 5)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 5)

            } else {
                //TODO: a terminer
                NoMealSelectedView()
                    .padding(.vertical, 20)
                    .padding(.horizontal, 5)
            }
            
            IngredientListView()
                .shadow(color: Color.theme.opacity(0.3),radius: 6, x: 5, y: 5)

                .padding(EdgeInsets(top: 20, leading: 5, bottom: 20, trailing: 20))
                .frame(minWidth: 300, maxWidth: 350)
            
        }
        .frame(minWidth: 1150)
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
        MealItem(title: "Raclette", ingredients: []),
        MealItem(title: "Hamburger maison", ingredients: []),
        MealItem(title: "Hot dogs", ingredients: []),
        MealItem(title: "Poisson pané", ingredients: []),
        MealItem(title: "Quiche lorraine", ingredients: []),
        MealItem(title: "Lasagnes", ingredients: [])
    ]
    
    for ingredient in ingredients { container.mainContext.insert(ingredient) }
    for meal in meals { container.mainContext.insert(meal) }
    
    return MealsManager()
        .modelContainer(container)
}
