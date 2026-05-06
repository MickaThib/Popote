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
    
    var body: some View {
        ScrollView {
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
                HStack(alignment: .lastTextBaseline) {
                    if isEditing {
                        TextField("Nom de la recette", text: $meal.title)
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                            .padding(.vertical)
                    } else {
                        Text(meal.title)
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                            .padding(.vertical)
                    }
                    Spacer()
                    Button("Modifier", systemImage: "pencil") {
                        isEditing.toggle()
                        try? modelContext.save()
                    }
                    .buttonStyle(.borderless)
                    //.labelStyle(.iconOnly)
                    //.font(.system(size: 18))
                }
                .frame(maxWidth: 500)
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text("Ingrédients")
                        .font(.headline)
                    
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
                            .fill(Color.green.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isTargeted ? Color.green : Color.clear, lineWidth: 2)
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
                    
                    TextField("Ajouter des notes...", text: $meal.notes, axis: .vertical)
                        .lineLimit(5...10)
                }
                .frame(maxWidth: 500)
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

#Preview {
    EditMealView(meal: MealItem(title: "Pâtes bolognaises", photo: nil, ingredients: [
        MealIngredient(ingredient: Ingredient(name: "Pâtes"), quantity: 1),
        MealIngredient(ingredient: Ingredient(name: "Sauce tomate"), quantity: 1),
        MealIngredient(ingredient: Ingredient(name: "Viande hâchée"), quantity: 1)
    ]))
}
