//
//  Ingredient.swift
//  Repascope
//
//  Created by Mickael on 29/04/2026.
//

import Foundation
import SwiftData

@Model
final class Ingredient: Hashable {
    var name: String
    
    @Relationship(deleteRule: .cascade, inverse: \MealIngredient.ingredient)
        var mealIngredients: [MealIngredient] = []
    
    init(name: String) {
        self.name = name
    }
}
