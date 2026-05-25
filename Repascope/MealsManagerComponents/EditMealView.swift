//
//  EditMealView.swift
//  Repascope
//
//  Created by Mickael Thibouret on 05/05/2026.
//

import SwiftUI
import SwiftData

struct EditMealView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Ingredient.name) private var ingredients: [Ingredient]

    
    @Bindable var meal: MealItem
    @Binding var startEditing: Bool
        
    var body: some View {
        VStack {
            
            // Photo
            PhotoView(meal: meal)
            
            ScrollView {
                
                EditMealTextField(startEditing: $startEditing, meal: meal)
                .frame(maxWidth: 500)
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text("Ingrédients")
                        .font(.headline)
                        .foregroundStyle(Color.themeContrast)
                    
                    EditMealIngredientList(meal: meal, ingredients: ingredients)
                    .frame(maxWidth: .infinity, minHeight: 80)
                    
                    
                    Text("Notes")
                        .font(.headline)
                        .foregroundStyle(Color.themeContrast)
                    
                    TextField("Ajouter des notes...", text: $meal.notes, axis: .vertical)
                        .lineLimit(5...10)
                }
                .frame(maxWidth: 500)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .frame(minWidth: 600)
        .background(
            Color.white
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct PhotoView: View {
    
    let meal: MealItem
    
    var body: some View {
        
        if let photo = meal.photo {
            Image(photo)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipped()
        } else {
            VStack {
                Image(systemName: "camera")
                    .font(.system(size: 50))
                
                Button("Ajouter une image") {
                    //TODO: Ajouter une image
                }
                .buttonStyle(.plain)
                .padding(.top, 5)
                
            }
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Color.theme.opacity(0.5))
        }
    }
}

struct EditMealTextField: View {
    
    @Environment(\.modelContext) private var modelContext

    @State private var isEditing = false
    @Binding var startEditing: Bool
    @FocusState private var titleFocused: Bool
    @Bindable var meal: MealItem
    
    var body: some View {
        HStack {
            if isEditing {
                TextField("Nom de la recette", text: $meal.title)
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.themeContrast)
                    .padding(.vertical, 16)
                    .focused($titleFocused)
                    .onSubmit {
                        isEditing = false
                        try? modelContext.save()
                    }
            } else {
                Text(meal.title)
                    .font(.system(size: 30))
                    .foregroundStyle(Color.theme)
                    .fontWeight(.bold)
                    .padding(.vertical, 20)
            }
            Spacer()
            Button("Modifier", systemImage: "pencil") {
                isEditing.toggle()
                try? modelContext.save()
            }
            .buttonStyle(.borderless)
        }
        .onChange(of: startEditing) { _, newValue in
            if newValue {
                isEditing = true
                startEditing = false
                Task { @MainActor in
                    titleFocused = true  // décaler après le rendu
                }
            }
        }
        .onChange(of: meal) { _, _ in
            isEditing = false
        }
    }
}

struct EditMealIngredientList: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var meal: MealItem
    let ingredients: [Ingredient]
    @State private var isTargeted = false
    @State private var showAddIngredientSheet = false
    
    var body: some View {
        ingredientListContent
            .frame(maxWidth: .infinity)
            .background(backgroundShape)
            .overlay(borderShape)
            .animation(.easeInOut(duration: 0.15), value: isTargeted)
            .dropDestination(
                for: IngredientTransfer.self,
                action: handleDrop,
                isTargeted: { isTargeted = $0 }
            )
            .sheet(isPresented: $showAddIngredientSheet) {

                IngredientAddSheet(
                    existingIngredients: ingredients
                ) { name in
                    let newIngredient = MealIngredient(ingredient: Ingredient(name: name), quantity: 1)
                    meal.ingredients.append(newIngredient)
                    modelContext.insert(newIngredient)
                    do { try modelContext.save() } catch { print(error) }
                }
            }
    }
    
    private var ingredientListContent: some View {
        
        VStack(alignment: .trailing, spacing: 0) {
            if meal.ingredients.isEmpty {
                Text("Glisser des ingrédients ici")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
            } else {
                ingredientsList
                    .padding(.top, 10)
            }
            
            Spacer()
            
            Button {
                showAddIngredientSheet = true
            } label: {
                Image(systemName: "plus.circle")
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(Color.themeContrast)
                    .padding()
            }
            .buttonStyle(.plain)
        }
    }
    
    private var ingredientsList: some View {
        ForEach($meal.ingredients) { $ingredient in
            IngredientStepperLine(
                ingredient: $ingredient,
                onDelete: {
                    deleteIngredient(ingredient)
                }
            )
            .frame(height: 30)
        }
    }
    
    private var backgroundShape: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(isTargeted ? Color.theme.opacity(0.1) : Color.theme.opacity(0.05))
    }
    
    private var borderShape: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color.theme, lineWidth: isTargeted ? 2 : 1)
    }
    
    private func deleteIngredient(_ ingredient: MealIngredient) {
        meal.ingredients.removeAll { $0.id == ingredient.id }
        try? modelContext.save()
    }
    
    private func handleDrop(_ transfers: [IngredientTransfer], _ location: CGPoint) -> Bool {
        for transfer in transfers {
            guard let ingredient = modelContext.model(for: transfer.persistentID) as? Ingredient else {
                print("🔴 ingredient introuvable")
                continue
            }
            
            let mealIngredient = MealIngredient(ingredient: ingredient, quantity: 1)
            meal.ingredients.append(mealIngredient)
        }
        
        try? modelContext.save()
        return true
    }
}

#Preview {
    EditMealView(meal: MealItem(title: "Pâtes bolognaises", photo: nil, ingredients: [
        MealIngredient(ingredient: Ingredient(name: "Pâtes"), quantity: 1),
        MealIngredient(ingredient: Ingredient(name: "Sauce tomate"), quantity: 1),
        MealIngredient(ingredient: Ingredient(name: "Viande hâchée"), quantity: 1)
    ]), startEditing: .constant(false))
    .frame(height: 800)
}
