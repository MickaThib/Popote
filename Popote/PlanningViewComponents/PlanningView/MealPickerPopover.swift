//
//  MealPickerPopover.swift
//  Popote
//
//  Created by Mickael on 17/05/2026.
//

import SwiftUI
import SwiftData

struct MealPickerPopover: View {
    
    let meals: [MealItem]
    let onSelect: (MealItem) -> Void
    @State private var hoveredMealID: MealItem.ID?
    
    var body: some View {
        
        if meals.isEmpty {
            VStack {
                Spacer()
                Text("Aucun repas enrgistré")
                    .font(.headline)
                Text("Ajoutez des repas\ndans l'onglet \"Repas\"")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(.vertical)
            .padding(.horizontal, 20)
        } else {
            
            List(meals) { meal in
                Button {
                    onSelect(meal)
                } label: {
                    HStack {
                        Text(meal.title)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.themeContrast)
                        
                        Spacer()
                    }
                    .padding(.vertical, 7)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(hoveredMealID == meal.id ? Color.theme.opacity(0.2) : Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.theme)
                    )
                    .onHover { hover in
                        hoveredMealID = hover ? meal.id : nil
                    }
                }
                .buttonStyle(.plain)
                .listRowSeparator(.hidden)
            }
            .frame(width: 300, height: 350)
        }
    }
}

#Preview {
    let meals = [
        MealItem(title: "Pâtes carbo"),
        MealItem(title: "Spaghetti bolognaise"),
        MealItem(title: "Quiche lorraine"),

    ]
    MealPickerPopover(meals: meals, onSelect: {_ in })
}
