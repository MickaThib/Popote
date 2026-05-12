//
//  Untitled.swift
//  Repascope
//
//  Created by Mickael Thibouret on 12/05/2026.
//

import Foundation
import SwiftData

@Model
final class DayMeals {
    var date: Date
    var noonMeal1: MealItem?
    var noonMeal2: MealItem?
    var eveningMeal1: MealItem?
    var eveningMeal2: MealItem?
    
    init(date: Date, noonMeal1: MealItem? = nil, noonMeal2: MealItem? = nil, eveningMeal1: MealItem? = nil, eveningMeal2: MealItem? = nil) {
        self.date = date
        self.noonMeal1 = noonMeal1
        self.noonMeal2 = noonMeal2
        self.eveningMeal1 = eveningMeal1
        self.eveningMeal2 = eveningMeal2
    }
}
