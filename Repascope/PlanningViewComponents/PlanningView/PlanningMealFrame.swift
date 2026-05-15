//
//  PlanningMealFrame.swift
//  Repascope
//
//  Created by Mickael Thibouret on 30/04/2026.
//

import SwiftUI
import SwiftData

struct PlanningMealFrame: View {
    
    @Environment(\.modelContext) private var context
    
    let day: Date
    let slot: MealSlot
    @State var guests: String = ""
    @State var notes: String = ""
    let plannedMeals: [PlannedMeal]
    
    var body: some View {
        VStack {
            HStack {
                TextField("Convives", text: $guests)
                    .textFieldStyle(.plain)
                TextField("Notes", text: $notes)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 7)
            .padding(.top, 7)
            
            if plannedMeals.count == 0 {
                // Si aucun repas n'est prévu
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray.opacity(0.2))
                    .frame(minHeight: 40, maxHeight: .infinity)
                    .padding(.horizontal, 7)
                    .padding(.bottom, 7)
                    .overlay {
                        Text("Aucun repas prévu")
                            .font(.callout)
                            .foregroundStyle(.gray)
                    }
            } else if plannedMeals.count < 2 {
                // Si un seul repas est prévu : prévoir espace pour en ajouter un autre
                HStack {
                    PlanningMealItem(meal: plannedMeals.first?.meal, deleteAction: {delete(plannedMeal: plannedMeals.first)})
                        .frame(minHeight: 40, maxHeight: .infinity)
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.clear)
                        .stroke(Color.gray.opacity(0.2))
                        .frame(maxWidth: 40)
                        .overlay {
                            Image(systemName: "plus")
                        }
                }
                .padding(.horizontal, 7)
                .padding(.bottom, 7)
            } else {
                // Si deux repas (ou plus) sont prévus : répartir cases à égalité
                HStack {
                    ForEach(plannedMeals) { pm in
                        PlanningMealItem(meal: pm.meal, deleteAction: {delete(plannedMeal: pm)})
                            .frame(minHeight: 40, maxHeight: .infinity)
                    }
                }
                .padding(.horizontal, 7)
                .padding(.bottom, 7)
            }
        }
        .frame(minWidth: 150, maxWidth: .infinity)
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray)
        }
    }
    
    func delete(plannedMeal: PlannedMeal?) {
        if let plannedMeal {
            context.delete(plannedMeal)
            do {
                try context.save()
            } catch {
                print("Error deleting plannedMeal \(plannedMeal.meal?.title ?? "Unknown")")
            }
        }
        
    }
}

#Preview {
    let meal1 = MealItem(title: "Quiche lorraine", photo: nil)
    let meal2 = MealItem(title: "Haricots verts", photo: nil)
    let pm1 = PlannedMeal(date: Date(), slot: .noon, position: 0, meal: meal1)
    let pm2 = PlannedMeal(date: Date(), slot: .noon, position: 1, meal: meal2)
    PlanningMealFrame(day: Date(), slot: .noon, plannedMeals: [pm1, pm2])
}
