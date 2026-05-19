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
                .foregroundStyle(bgColor())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(isHovering ? Color.white.opacity(0.5) : Color.white)
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .stroke(bgColor(), lineWidth: 2)
        }
        .overlay(alignment: .topTrailing, content: {
            if isHovering {
                Button("Supprimer", systemImage: "xmark.circle.fill") {
                    deleteAction()
                }
                .foregroundStyle(bgColor())
                .buttonStyle(.plain)
                .labelStyle(.iconOnly)
                .padding(5)
            }
        })
        .onHover { hover in
            isHovering = hover
        }
    }
    
    func bgColor() -> Color {
        if slot == .noon {
            return Color.blue
        } else {
            return Color.pink
        }
    }
}

#Preview {
    let mealItem = MealItem(title: "Pates carbo", photo: nil)
    PlanningMealItem(meal: mealItem, slot: .noon, deleteAction: {})
}
