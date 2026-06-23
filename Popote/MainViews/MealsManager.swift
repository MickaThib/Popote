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
    @Environment(AppSettings.self) private var appSettings

    @State var selectedMeal: MealItem? = nil
    @State var isEditingNewMeal: Bool = false
    @State var showSettings: Bool = false
    
    var body: some View {
        HStack {
            
            MealListView(
                selectedMeal: $selectedMeal,
                selectMeal: { meal in
                    checkMealValidity(selectedMeal)
                    selectedMeal = meal
                },
                addMeal: {
                    
                    checkMealValidity(selectedMeal)
                    
                    let newMeal = MealItem(title: "Nouveau plat")
                    modelContext.insert(newMeal)
                    try? modelContext.save()
                    selectedMeal = newMeal
                    
                    Task { @MainActor in
                        isEditingNewMeal = true  // déclenché après que la vue est montée
                    }
                    
                })
            .shadow(color: appSettings.mainColor.opacity(0.3),radius: 6, x: 5, y: 5)
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 5))
            .frame(minWidth: 300, maxWidth: 350)
            
            if let meal = selectedMeal {
                EditMealView(meal: meal, startEditing: $isEditingNewMeal)
                    .shadow(color: appSettings.mainColor.opacity(0.3),radius: 6, x: 5, y: 5)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 5)
                
            } else {
                NoMealSelectedView()
                    .padding(.vertical, 20)
                    .padding(.horizontal, 5)
            }
            
            IngredientListView()
                .shadow(color: appSettings.mainColor.opacity(0.3),radius: 6, x: 5, y: 5)
            
                .padding(EdgeInsets(top: 20, leading: 5, bottom: 20, trailing: 20))
                .frame(minWidth: 300, maxWidth: 350)
            
        }
        .frame(minWidth: 1150)
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Button {
                    showSettings = true
                } label: {
                    Label("Réglages", systemImage: "gear")
                        .labelStyle(.iconOnly)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
           SettingsView()
        }
    }
    
    private func checkMealValidity(_ meal: MealItem?) {
        guard let meal else { return }

        let titleIsDefault = meal.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || meal.title == "Nouveau plat"

        let hasNoIngredients = meal.ingredients.isEmpty
        let hasNoNotes = meal.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasNoImage = meal.imageData == nil

        guard titleIsDefault && hasNoIngredients && hasNoNotes && hasNoImage else {
            try? modelContext.save()
            return
        }

        modelContext.delete(meal)

        if selectedMeal === meal {
            selectedMeal = nil
        }

        do {
            try modelContext.save()
        } catch {
            print("Erreur suppression repas invalide :", error)
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
