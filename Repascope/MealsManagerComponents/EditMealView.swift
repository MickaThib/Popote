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
        
    var body: some View {
        VStack {
                
                if let photo = meal.photo {
                    Image(photo)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                } else {
                    Image(systemName: "camera")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.white)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.3))
                }
                
                Text(meal.title)
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                    .padding()
                
                VStack(alignment: .leading) {
                                        
                    Text("Ingrédients")
                        .font(.headline)
                    
                    VStack(alignment: .leading) {
                        ForEach(meal.ingredients) { ingredient in
                            HStack{
                                Text(ingredient.ingredient.name)
                                Spacer()
                                Text("Quantité : \(ingredient.quantity)")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 200, alignment: .topLeading)
                    .background(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isTargeted ? Color.blue : Color.clear, lineWidth: 2)
                    )
                    .animation(.easeInOut(duration: 0.15), value: isTargeted)
                    .dropDestination(for: IngredientTransfer.self, action: { transfers, _ in
                        //print("🟢 drop reçu : \(transfers.count) éléments")
                        for transfer in transfers {
                            guard let ingredient = modelContext.model(for: transfer.persistentID) as? Ingredient else {
                                print("🔴 ingredient introuvable")
                                continue
                            }
                            //print("✅ ingredient trouvé : \(ingredient.name)")
                            let mealIngredient = MealIngredient(ingredient: ingredient, quantity: 1)
                            meal.ingredients.append(mealIngredient)
                        }
                        try? modelContext.save()
                        return true
                    }, isTargeted: { isTargeted = $0 })
                    
                    TextField("Notes", text: $meal.notes )
                        .lineLimit(5...10)
                        .padding(.vertical)
                }
                .frame(maxWidth: 500)
                
                Spacer()

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
