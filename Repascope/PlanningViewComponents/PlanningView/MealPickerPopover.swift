//
//  MealPickerPopover.swift
//  Repascope
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
                    
            List(meals) { meal in
                Button {
                    onSelect(meal)
                } label: {
                    HStack {
                        Text(meal.title)
                            .fontWeight(.medium)

                        Spacer()
                    }
                    .padding(.vertical, 7)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(hoveredMealID == meal.id ? Color.accentColor.opacity(0.2) : Color.accentColor.opacity(0.1))
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

#Preview {
    let meals = [
        MealItem(title: "Pâtes carbo", photo: nil),
        MealItem(title: "Spaghetti bolognaise", photo: nil),
        MealItem(title: "Quiche lorraine", photo: nil),

    ]
    MealPickerPopover(meals: meals, onSelect: {_ in })
}
