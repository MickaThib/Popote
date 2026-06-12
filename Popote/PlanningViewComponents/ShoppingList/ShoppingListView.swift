//
//  ShoppingList.swift
//  Popote
//
//  Created by Mickael on 29/04/2026.
//
// Point d'entrée version complète, présente dans la vue planning globale

import SwiftUI
import SwiftData

struct ShoppingListView: View {
    
    let date: Date
    
    init(date: Date) {
        self.date = date
    }
    
    
    var body: some View {
        
        ShoppingListContainerView(date: date) { currentList, startOfWeek in
            ShoppingListFullView(
                startOfWeek: startOfWeek,
                currentList: currentList
            )
        }
    }
    
}
