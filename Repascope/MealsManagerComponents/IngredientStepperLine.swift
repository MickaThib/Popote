//
//  IngredientStepperLine.swift
//  Repascope
//
//  Created by Mickael on 05/05/2026.
//

import SwiftUI

struct IngredientStepperLine: View {
    
    @Binding var ingredient: MealIngredient
    var onDelete: (() -> Void)?
    
    var body: some View {
        HStack{
            Text(ingredient.ingredient.name)
            Spacer()
            Text("x \(ingredient.quantity)")
            Stepper("", value: $ingredient.quantity, in: 0...99)
                .labelsHidden()
                .onChange(of: ingredient.quantity) { _, newValue in
                    if newValue == 0 {
                        if let onDelete = onDelete {
                            onDelete()
                        }
                    }
                }
            
            
        }
        .padding(.horizontal)
    }
}

#Preview {
    IngredientStepperLine(ingredient: .constant(MealIngredient(ingredient: Ingredient(name: "Brioche"), quantity: 1)))
        .frame(height: 40)
}
