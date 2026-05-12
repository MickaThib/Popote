//
//  MealsPlanningViewModel.swift
//  Repascope
//
//  Created by Mickael Thibouret on 12/05/2026.
//

import Foundation

class MealsPlanningViewModel {
    
    func fetchDayMealsFor(day: Date) -> DayMeals? {
        return DayMeals(day: day)
    }
}
