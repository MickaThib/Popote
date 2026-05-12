//
//  Untitled.swift
//  Repascope
//
//  Created by Mickael Thibouret on 12/05/2026.
//

import Foundation
import SwiftData

@Model
class PlannedMeal {
    var date: Date
    var slot: MealSlot
    var position: Int        // 0 = premier repas, 1 = deuxième
    var meal: MealItem?

    init(date: Date, slot: MealSlot, position: Int, meal: MealItem? = nil) {
        self.date = Calendar.current.startOfDay(for: date)
        self.slot = slot
        self.position = position
        self.meal = meal
    }
}

enum MealSlot:String, Codable, CaseIterable {
    case noon = "Midi"
    case evening = "Soir"
}
