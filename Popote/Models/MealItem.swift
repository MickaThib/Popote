//
//  MealItem.swift
//  Popote
//
//  Created by Mickael on 01/05/2026.
//

import Foundation
import SwiftData

@Model
final class MealItem {
    var title: String
    var imageData: Data?
    var notes: String = ""
    
    @Relationship(deleteRule: .cascade)
    var ingredients: [MealIngredient]
    
    @Relationship(deleteRule: .cascade, inverse: \PlannedMeal.meal)
    var plannedMeals: [PlannedMeal] = []

    init(title: String, imageData: Data? = nil, ingredients: [MealIngredient] = []) {
        self.title = title
        self.imageData = imageData
        self.ingredients = ingredients
    }
}
