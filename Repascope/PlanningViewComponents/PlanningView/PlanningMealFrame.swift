//
//  PlanningMealFrame.swift
//  Repascope
//
//  Created by Mickael Thibouret on 30/04/2026.
//

import SwiftUI
import SwiftData

struct PlanningMealFrame: View {
    
    @Environment(\.modelContext) private var modelContext
    
    let day: Date
    let slot: MealSlot
    let viewModel:PlanningViewModel
    @Query(sort: \MealItem.title) private var meals: [MealItem]
    let plannedMeals:[PlannedMeal]
    
    @State private var guests: String = ""
    @State private var notes: String = ""
    @State private var isTargeted:Bool = false
    @State private var targetedReplacementID: PersistentIdentifier?
    @State private var showMealPicker = false
    
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
            
            if plannedMeals.isEmpty {
                // Si aucun repas n'est prévu
                emptyMealView
                    .padding(.horizontal, 7)
                    .padding(.bottom, 7)
                
            } else if plannedMeals.count == 1 {
                // Si un seul repas est prévu : prévoir espace "plus" pour en ajouter un autre
                singleMealView
                    .padding(.horizontal, 7)
                    .padding(.bottom, 7)
            } else {
                // Si deux repas (ou plus) sont prévus : répartir cases à égalité
                multipleMealsView
                    .padding(.horizontal, 7)
                    .padding(.bottom, 7)
            }
        }
        .frame(minWidth: 150, maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .fill(bgColor().opacity(0.15))
        }
    }
    
    private var emptyMealView: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(isTargeted ? Color.white.opacity(0.6) : Color.white)
            .frame(minHeight: 40, maxHeight: .infinity)
            .overlay {
                HStack(alignment: .firstTextBaseline, spacing: 30) {
                    Text("Aucun repas prévu")
                        .font(.callout)
                        .foregroundStyle(.gray)
                    Spacer()
                    Image(systemName: "plus")
                        .foregroundStyle(.gray)
                }
                .padding(.horizontal, 14)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(isTargeted ? bgColor().opacity(0.5) : Color.clear, lineWidth: 2)
            }
            .onTapGesture {
                showMealPicker = true
            }
            .popover(isPresented: $showMealPicker, attachmentAnchor: .point(.center), arrowEdge: .bottom) {
                mealPickerPopover()
            }
            .dropDestination(for: PlanningDropTransfer.self) { transfers, _ in
                handlePlanningDrop(transfers)
            } isTargeted: { targeted in
                isTargeted = targeted
            }
    }
    
    private var singleMealView: some View {
        HStack {
            if let plannedMeal = plannedMeals.first {
                replaceableMealItem(for: plannedMeal)
            }
            
            addMealDropZone
        }
    }
    
    private var addMealDropZone: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(isTargeted ? bgColor().opacity(0.2) : Color.clear)
            .frame(maxWidth: 40)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(
                        isTargeted ? bgColor().opacity(0.5) : bgColor().opacity(0.5),
                        lineWidth: isTargeted ? 2 : 1
                    )
            }
            .overlay {
                Image(systemName: "plus")
            }
            .onTapGesture {
                showMealPicker = true
            }
            .popover(isPresented: $showMealPicker, attachmentAnchor: .point(.center), arrowEdge: .bottom) {
                mealPickerPopover()
            }
            .dropDestination(for: PlanningDropTransfer.self) { transfers, _ in
                handlePlanningDrop(transfers)
            } isTargeted: { targeted in
                isTargeted = targeted
            }
    }
    
    private var multipleMealsView: some View {
        HStack {
            ForEach(plannedMeals) { plannedMeal in
                replaceableMealItem(for: plannedMeal)
            }
        }
    }
    
    private func handlePlanningDrop(_ transfers: [PlanningDropTransfer]) -> Bool {
        guard let transfer = transfers.first else {
            return false
        }
        
        switch transfer.kind {
            
        case .mealItem:
            guard let meal = modelContext.model(for: transfer.persistentID) as? MealItem else {
                print("🔴 MealItem introuvable")
                return false
            }
            
            viewModel.setPlannedMeal(
                meal,
                date: day,
                slot: slot,
                existingPlannedMeals: plannedMeals,
                modelContext: modelContext
            )
            
            return true
            
        case .plannedMeal:
            guard let plannedMeal = modelContext.model(for: transfer.persistentID) as? PlannedMeal else {
                print("🔴 PlannedMeal introuvable")
                return false
            }
            
            viewModel.movePlannedMeal(
                plannedMeal,
                to: day,
                slot: slot,
                plannedMealsForDestinationSlot: plannedMeals,
                modelContext: modelContext
            )
            
            return true
        }
    }
    
    private func handleReplacementDrop(
        _ transfers: [PlanningDropTransfer],
        replacing targetPlannedMeal: PlannedMeal
    ) -> Bool {
        guard let transfer = transfers.first else {
            return false
        }
        
        switch transfer.kind {
            
        case .mealItem:
            guard let meal = modelContext.model(for: transfer.persistentID) as? MealItem else {
                print("🔴 MealItem introuvable")
                return false
            }
            
            viewModel.replaceMeal(
                in: targetPlannedMeal,
                with: meal,
                modelContext: modelContext
            )
            
            return true
            
        case .plannedMeal:
            guard let sourcePlannedMeal = modelContext.model(for: transfer.persistentID) as? PlannedMeal else {
                print("PlannedMeal introuvable")
                return false
            }
            
            viewModel.swapPlannedMeals(sourcePlannedMeal, with: targetPlannedMeal, modelContext: modelContext)
            
            return true
        }
    }
    
    private func replaceableMealItem(for plannedMeal: PlannedMeal) -> some View {
        PlanningMealItem(
            meal: plannedMeal.meal,
            slot: plannedMeal.slot,
            deleteAction: {
                viewModel.delete(
                    plannedMeal: plannedMeal,
                    plannedMealsForSlot: plannedMeals,
                    modelContext: modelContext
                )
            }
        )
        .frame(minHeight: 40, maxHeight: .infinity)
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .stroke(
                    targetedReplacementID == plannedMeal.persistentModelID
                    ? bgColor()
                    : Color.clear,
                    lineWidth: 2
                )
        }
        .draggable(
            PlanningDropTransfer(persistentID: plannedMeal.persistentModelID, kind: .plannedMeal)
        ) {
            Text(plannedMeal.meal?.title ?? "Repas")
                .padding(8)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(bgColor().opacity(0.2))
                )
        }
        .dropDestination(for: PlanningDropTransfer.self) { transfers, _ in
            handleReplacementDrop(
                transfers,
                replacing: plannedMeal
            )
        } isTargeted: { targeted in
            if targeted {
                targetedReplacementID = plannedMeal.persistentModelID
            } else if targetedReplacementID == plannedMeal.persistentModelID {
                targetedReplacementID = nil
            }
        }
    }
    
    private func mealPickerPopover() -> some View {
        MealPickerPopover(meals: meals) { selectedMeal in
            viewModel.setPlannedMeal(
                selectedMeal,
                date: day,
                slot: slot,
                existingPlannedMeals: plannedMeals,
                modelContext: modelContext
            )

            showMealPicker = false
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
    let meal1 = MealItem(title: "Quiche lorraine", photo: nil)
    let meal2 = MealItem(title: "Haricots verts", photo: nil)
    let pm1 = PlannedMeal(date: Date(), slot: .noon, position: 0, meal: meal1)
    let pm2 = PlannedMeal(date: Date(), slot: .noon, position: 1, meal: meal2)
    
    PlanningMealFrame(
        day: Date(),
        slot: .noon,
        viewModel: PlanningViewModel(),
        plannedMeals: []
    )
}
