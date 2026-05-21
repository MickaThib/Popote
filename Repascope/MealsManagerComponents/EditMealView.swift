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
    
    @Bindable var meal: MealItem
    
    @State private var isTargeted = false
    @State private var isEditing = false
    @Binding var startEditing: Bool
    @FocusState private var titleFocused: Bool
    
    var body: some View {
        VStack {
            
            // Photo
            if let photo = meal.photo {
                Image(photo)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipped()
            } else {
                Image(systemName: "camera")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.white)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.3))
            }
            
            ScrollView {
                
                HStack(alignment: .lastTextBaseline) {
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
                .frame(maxWidth: 500)
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text("Ingrédients")
                        .font(.headline)
                        .foregroundStyle(Color.themeContrast)
                    
                    VStack(alignment: .center, spacing: 0) {
                        if meal.ingredients.isEmpty {
                            Text("Glisser des ingrédients ici")
                        } else {
                            ForEach(meal.ingredients.indices, id: \.self) { index in
                                IngredientStepperLine(
                                    ingredient: $meal.ingredients[index],
                                    onDelete: {
                                        meal.ingredients.remove(at: index)
                                        try? modelContext.save()
                                    })
                                .frame(height: 40)
                            }
                            Spacer(minLength: 40)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isTargeted ? Color.theme.opacity(0.1) : Color.theme.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.theme, lineWidth: isTargeted ? 2 : 1)
                    )
                    .animation(.easeInOut(duration: 0.15), value: isTargeted)
                    .dropDestination(for: IngredientTransfer.self, action: { transfers, _ in
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
                    }, isTargeted: { isTargeted = $0 })
                    
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
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
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

#Preview {
    EditMealView(meal: MealItem(title: "Pâtes bolognaises", photo: nil, ingredients: [
        MealIngredient(ingredient: Ingredient(name: "Pâtes"), quantity: 1),
        MealIngredient(ingredient: Ingredient(name: "Sauce tomate"), quantity: 1),
        MealIngredient(ingredient: Ingredient(name: "Viande hâchée"), quantity: 1)
    ]), startEditing: .constant(false))
}
