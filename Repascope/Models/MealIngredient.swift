//
//  MealIngredient.swift
//  Repascope
//
//  Created by Mickael on 01/05/2026.
//

import Foundation
import SwiftData

@Model
final class MealIngredient {
    var ingredient: Ingredient
    var quantity: Int

    init(ingredient: Ingredient, quantity: Int) {
        self.ingredient = ingredient
        self.quantity = quantity
    }
}
