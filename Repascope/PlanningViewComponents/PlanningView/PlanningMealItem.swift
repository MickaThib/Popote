//
//  PlanningMealItem.swift
//  Repascope
//
//  Created by Mickael Thibouret on 15/05/2026.
//

import SwiftUI

struct PlanningMealItem: View {
    
    let meal: MealItem?
    let deleteAction: () -> Void
    @State private var isHovering: Bool = false
    
    var body: some View {
        HStack {
            Text(meal?.title ?? "Unknown")
                .font(.headline)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.accentColor.opacity(0.2))
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .fill(isHovering ? Color.accentColor.opacity(0.2) : .clear)
        }
        .overlay(alignment: .topTrailing, content: {
            if isHovering {
                Button("Supprimer", systemImage: "xmark") {
                    deleteAction()
                }
                .labelStyle(.iconOnly)
                .padding(2)
            }
        })
        .onHover { hover in
            isHovering = hover
        }
    }
}

#Preview {
    let mealItem = MealItem(title: "Pates carbo", photo: nil)
    PlanningMealItem(meal: mealItem, deleteAction: {})
}
