//
//  PlanningMealItem.swift
//  Popote
//
//  Created by Mickael Thibouret on 15/05/2026.
//

import SwiftUI

struct PlanningMealItem: View {
    
    let meal: MealItem
    let slot: MealSlot
    let deleteAction: () -> Void
    @State private var isHovering: Bool = false
    let isTargetedForReplacement: Bool
    
    var body: some View {
        HStack {
            Text(meal.title)
                .font(.headline)
                .foregroundStyle(itemColor())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(
                            isTargetedForReplacement
                            ? Color.white.opacity(0.5)
                            : isHovering
                                ? Color.white.opacity(0.5)
                                : Color.white
                        )
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .stroke(itemColor(), lineWidth: 2)
        }
        .overlay(alignment: .topTrailing, content: {
            if isHovering {
                Button("Supprimer", systemImage: "xmark.circle.fill") {
                    deleteAction()
                }
                .foregroundStyle(itemColor())
                .buttonStyle(.plain)
                .labelStyle(.iconOnly)
                .padding(5)
            }
        })
        .onHover { hover in
            isHovering = hover
        }
    }
    
    func itemColor() -> Color {
        if slot == .noon {
            return Color.noon
        } else {
            return Color.evening
        }
    }
}

#Preview {
    let mealItem = MealItem(title: "Pates carbo")
    PlanningMealItem(meal: mealItem, slot: .noon, deleteAction: {}, isTargetedForReplacement: false)
}
