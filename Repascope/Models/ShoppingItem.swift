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
    var isChecked: Bool = false
    
    var shoppingList: ShoppingList?
    
    init(name: String, quantity: Int = 1) {
        self.name = name
        self.quantity = quantity
    }
}
