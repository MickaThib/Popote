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
    @Query(sort: \ShoppingList.weekStart) private var shoppingLists:[ShoppingList]

    
    let day: Date
    let slot: MealSlot
    let planningViewModel:PlanningViewModel
    let calendarViewModel: CalendarViewModel
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
                .fill(itemColor().opacity(0.3))
        }
    }
    
    private var emptyMealView: some View {
        HStack(alignment: .firstTextBaseline, spacing: 30) {
            Text("Aucun repas prévu")
                .font(.callout)
                .foregroundStyle(.gray)
            
            Spacer()
            
            Button("Plus", systemImage: "plus") {
                showMealPicker = true
                
            }
            .foregroundStyle(.gray)
            .frame(maxWidth: 40)
            .frame(maxHeight: .infinity)
            .buttonStyle(.plain)
            .labelStyle(.iconOnly)
            .popover(isPresented: $showMealPicker, attachmentAnchor: .point(.center), arrowEdge: .bottom) {
                mealPickerPopover()
            }
        }
        .padding(.leading, 14)
        .frame(minHeight: 40, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(isTargeted ? Color.white.opacity(0.6) : Color.white)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .stroke(isTargeted ? itemColor().opacity(0.5) : Color.clear, lineWidth: 2)
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
            .fill(isTargeted ? itemColor().opacity(0.2) : Color.clear)
            .frame(maxWidth: 40)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(
                        isTargeted ? itemColor() : itemColor().opacity(0.5),
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
            
            planningViewModel.setPlannedMeal(
                meal,
                date: day,
                slot: slot,
                existingPlannedMeals: plannedMeals,
                modelContext: modelContext
            )
            
            addIngredientsToShoppingListFor(meal: meal, to: day)
            
            return true
            
        case .plannedMeal:
            guard let plannedMeal = modelContext.model(for: transfer.persistentID) as? PlannedMeal else {
                print("🔴 PlannedMeal introuvable")
                return false
            }
            
            planningViewModel.movePlannedMeal(
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
            
            planningViewModel.replaceMeal(
                in: targetPlannedMeal,
                with: meal,
                modelContext: modelContext
            )
            //TODO: Supprimer les ingrédients des repas remplacés
            addIngredientsToShoppingListFor(meal: meal, to: day)
            
            return true
            
        case .plannedMeal:
            guard let sourcePlannedMeal = modelContext.model(for: transfer.persistentID) as? PlannedMeal else {
                print("PlannedMeal introuvable")
                return false
            }
            
            planningViewModel.swapPlannedMeals(sourcePlannedMeal, with: targetPlannedMeal, modelContext: modelContext)
            
            return true
        }
    }
    
    private func replaceableMealItem(for plannedMeal: PlannedMeal) -> some View {
        PlanningMealItem(
            meal: plannedMeal.meal,
            slot: plannedMeal.slot,
            deleteAction: {
                planningViewModel.delete(
                    plannedMeal: plannedMeal,
                    plannedMealsForSlot: plannedMeals,
                    modelContext: modelContext
                )
                //TODO: Supprimer les ingrédients des repas remplacés
            }
        )
        .frame(minHeight: 40, maxHeight: .infinity)
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .stroke(
                    targetedReplacementID == plannedMeal.persistentModelID
                    ? itemColor()
                    : Color.clear,
                    lineWidth: 2
                )
        }
        .draggable(
            PlanningDropTransfer(persistentID: plannedMeal.persistentModelID, kind: .plannedMeal)
        ) {
            Text(plannedMeal.meal?.title ?? "Repas")
                .foregroundStyle(itemColor())
                .fontWeight(.bold)
                .padding(8)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(itemColor(), lineWidth: 4)
                )
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.white)
                )
                .opacity(0.5)
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
    
    private func addIngredientsToShoppingListFor(meal: MealItem, to date: Date) {
                
        guard let startOfWeek = CalendarViewModel.firstDayOfWeek(
            startWeekday: .saturday,
            from: date
        ) else {
            return
        }
        
        let normalizedStartOfWeek = CalendarViewModel.calendar.startOfDay(for: startOfWeek)
        
        let currentShoppingList = shoppingLists.first {
            CalendarViewModel.calendar.isDate($0.weekStart, inSameDayAs: normalizedStartOfWeek)
        }
        
        let shoppingList: ShoppingList
        
        
        if let currentShoppingList {
            shoppingList = currentShoppingList
            
            for item in shoppingList.items {
                item.justAdded = false
            }
            
        } else {
            shoppingList = ShoppingList(weekStart: normalizedStartOfWeek)
            modelContext.insert(shoppingList)
        }
        
        for ingredient in meal.ingredients {
            if let existingItem = shoppingList.items.first(where: { $0.name == ingredient.ingredient.name }) {
                existingItem.quantity += ingredient.quantity
                existingItem.justAdded = true
            } else {
                let item = ShoppingItem(
                    name: ingredient.ingredient.name,
                    quantity: ingredient.quantity,
                    justAdded: true
                )
                shoppingList.items.append(item)
            }
        }
        
        do { try modelContext.save() } catch { print("Error : \(error)") }
    }
    
    private func mealPickerPopover() -> some View {
        MealPickerPopover(meals: meals) { selectedMeal in
            planningViewModel.setPlannedMeal(
                selectedMeal,
                date: day,
                slot: slot,
                existingPlannedMeals: plannedMeals,
                modelContext: modelContext
            )
            
            addIngredientsToShoppingListFor(meal: selectedMeal, to: day)
            
            showMealPicker = false
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
    //let meal1 = MealItem(title: "Quiche lorraine", photo: nil)
    //let meal2 = MealItem(title: "Haricots verts", photo: nil)
    //let pm1 = PlannedMeal(date: Date(), slot: .noon, position: 0, meal: meal1)
    //let pm2 = PlannedMeal(date: Date(), slot: .noon, position: 1, meal: meal2)
    
    PlanningMealFrame(
        day: Date(),
        slot: .noon,
        planningViewModel: PlanningViewModel(),
        calendarViewModel: CalendarViewModel(),
        plannedMeals: []
    ).frame(width: 400, height: 80)
    
    PlanningMealFrame(
        day: Date(),
        slot: .evening,
        planningViewModel: PlanningViewModel(),
        calendarViewModel: CalendarViewModel(),
        plannedMeals: []
    ).frame(width: 400, height: 80)
}
