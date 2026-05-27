//
//  ShoppingListItem.swift
//  Repascope
//
//  Created by Mickael on 29/04/2026.
//

import Foundation
import SwiftData

@Model
final class ShoppingItem {
    var name: String = ""
    var quantity: Int
    var category: ShoppingCategory
    var isChecked: Bool = false
    var justAdded: Bool
    
    var shoppingList: ShoppingList?
    
    init(name: String, quantity: Int = 1, category: ShoppingCategory = .food, justAdded: Bool = false) {
        self.name = name
        self.quantity = quantity
        self.category = category
        self.justAdded = justAdded
    }
}

enum ShoppingCategory: String, Codable, CaseIterable {
    case food = "Repas"
    case snack = "Petit déjeuner/Goûter"
    case other = "Autres"
}
