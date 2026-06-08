//
//  GuestsGroup.swift
//  Popote
//
//  Created by Mickael Thibouret on 29/05/2026.
//

import Foundation
import SwiftData

@Model
final class GuestsGroup {
    var title: String
    var colorHex: String
    
    @Relationship(inverse: \Guest.groups)
    var guests: [Guest]
    
    @Relationship(inverse: \PlannedMeal.guestsGroups)
    var plannedMeals: [PlannedMeal] = []
    
    init(title: String, colorHex: String = "6762A4", guests: [Guest] = []) {
        self.title = title
        self.colorHex = colorHex
        self.guests = guests
    }
}
