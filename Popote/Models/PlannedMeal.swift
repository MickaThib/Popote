//
//  Untitled.swift
//  Popote
//
//  Created by Mickael Thibouret on 12/05/2026.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class PlannedMeal {
    var date: Date
    var slot: MealSlot
    var position: Int        // 0 = premier repas, 1 = deuxième
    
    var meal: MealItem?
    
    var guests: [Guest]
    var guestsGroups: [GuestsGroup]
    
    var notes: String?

    init(date: Date, slot: MealSlot, position: Int, meal: MealItem? = nil, guests: [Guest] = [], guestsGroups: [GuestsGroup] = [], notes: String? = nil) {
        self.date = Calendar.current.startOfDay(for: date)
        self.slot = slot
        self.position = position
        self.meal = meal
        self.guests = guests
        self.guestsGroups = guestsGroups
        self.notes = notes
    }
}

enum MealSlot:String, Codable, CaseIterable {
    case noon = "Midi"
    case evening = "Soir"
    
    func color() -> Color {
        switch self {
        case .evening: return Color.theme
        case .noon: return Color.noon
        }
    }
}
