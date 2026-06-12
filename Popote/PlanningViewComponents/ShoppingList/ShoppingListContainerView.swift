//
//  ShoppingListContainer.swift
//  Popote
//
//  Created by Mickael on 12/06/2026.
//
// Cette vue a un seul rôle : trouver la bonne ShoppingList pour une date donnée.
// Elle ne s’occupe ni du header, ni du rendu des items, ni de l’export.

import SwiftUI
import SwiftData

struct ShoppingListContainerView<Content: View>: View {
    
    let startOfWeek: Date
    let content: (ShoppingList?, Date) -> Content
    
    @Query private var shoppingLists: [ShoppingList]
    
    private var currentList: ShoppingList? { shoppingLists.first }
    
    init(
            date: Date,
            @ViewBuilder content: @escaping (ShoppingList?, Date) -> Content
        ) {
            let start = CalendarViewModel.shoppingWeekStart(for: date)!
            self.startOfWeek = start
            self.content = content
            
            let end = CalendarViewModel.calendar.date(
                byAdding: .day,
                value: 1,
                to: start
            )!
            
            _shoppingLists = Query(
                filter: #Predicate<ShoppingList> { list in
                    list.weekStart >= start && list.weekStart < end
                },
                sort: \.weekStart
            )
        }
    
    var body: some View {
        content(currentList, startOfWeek)
    }
}
