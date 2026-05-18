//
//  PlanningMealItem.swift
//  Repascope
//
//  Created by Mickael Thibouret on 15/05/2026.
//

import SwiftUI

struct PlanningMealItem: View {
    
    let meal: MealItem?
    let slot: MealSlot
    let deleteAction: () -> Void
    @State private var isHovering: Bool = false
    
    var body: some View {
        HStack {
            Text(meal?.title ?? "Repas supprimé")
                .font(.headline)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(isHovering ? bgColor().opacity(0.7) : bgColor().opacity(0.6))
                )
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
    
    func bgColor() -> Color {
        if slot == .noon {
            return Color.mint
        } else {
            return Color.pink
        }
    }
}

#Preview {
    let mealItem = MealItem(title: "Pates carbo", photo: nil)
    PlanningMealItem(meal: mealItem, slot: .noon, deleteAction: {})
}
