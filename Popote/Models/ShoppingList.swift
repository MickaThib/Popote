//
//  ShoppingList.swift
//  Popote
//
//  Created by Mickael on 14/05/2026.
//

import Foundation
import SwiftData

@Model
class ShoppingList {

    var weekStart: Date

    @Relationship(
        deleteRule: .cascade,
        inverse: \ShoppingItem.shoppingList
    )
    var items: [ShoppingItem] = []

    init(weekStart: Date, items: [ShoppingItem] = []) {
        self.weekStart = weekStart
        self.items = items
    }
}

extension ShoppingList {
    func clearJustAddedFlags() {
        for item in items {
            item.justAdded = false
        }
    }
}
