//
//  PlanningMealFrame.swift
//  Popote
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
    
    @Query(sort: \MealItem.title) private var meals: [MealItem]
    let plannedMeals:[PlannedMeal]
    private var plannedMealsWithMeal: [PlannedMeal] {
        plannedMeals.filter { $0.meal != nil }
    }
    
    let allGuests: [Guest]
    let allGroups: [GuestsGroup]
    
    //@State private var guests: String = ""
    @State private var notes: String = ""
    @State private var isTargeted:Bool = false
    @State private var targetedReplacementID: PersistentIdentifier?
    @State private var showMealPicker = false
    
    var body: some View {
        VStack {
            ConvivesField(
                day: day,
                slot: slot,
                plannedMeals: plannedMeals,
                allGuests: allGuests,
                allGroups: allGroups
            )
            .padding(.horizontal, 7)
            .padding(.top, 7)
            
            if plannedMealsWithMeal.isEmpty {
                // Si aucun repas n'est prévu
                emptyMealView
                    .padding(.horizontal, 7)
                    .padding(.bottom, 7)
                
            } else if plannedMealsWithMeal.count == 1 {
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
            if let plannedMeal = plannedMealsWithMeal.first {
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
                        itemColor(),
                        lineWidth: isTargeted ? 2 : 1
                    )
            }
            .overlay {
                Image(systemName: "plus")
                    .foregroundStyle(itemColor())
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
            ForEach(plannedMealsWithMeal) { plannedMeal in
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
                print("MealItem introuvable")
                return false
            }
            
            let oldMeal = targetPlannedMeal.meal
            
            planningViewModel.replaceMeal(
                in: targetPlannedMeal,
                with: meal,
                modelContext: modelContext
            )
            
            // Supprime les anciens ingrédients
            if let oldMeal {
                removeIngredientsFromShoppingList(for: oldMeal, on: day)
            }
            // Ajoute les nouveaux ingrédients
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
        
        guard let meal = plannedMeal.meal else {
            return AnyView(emptyMealView)
        }
        
        return AnyView(
            PlanningMealItem(
                meal: meal,
                slot: plannedMeal.slot,
                deleteAction: {
                    let deletedMeal = plannedMeal.meal
                    planningViewModel.delete(
                        plannedMeal: plannedMeal,
                        plannedMealsForSlot: plannedMeals,
                        modelContext: modelContext
                    )
                    // Supprimer les ingrédients des repas remplacés
                    if let deletedMeal {
                        removeIngredientsFromShoppingList(for: deletedMeal, on: day)
                    }
                },
                isTargetedForReplacement: targetedReplacementID == plannedMeal.persistentModelID
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
                        .padding(.vertical, 8)
                        .padding(.horizontal, 50)
                        .frame(height: 40)
                        .background(.white, in: RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(itemColor(), lineWidth: 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
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
        )
    }
    
    private func normalizedStartOfWeek(for day: Date) -> Date? {
        guard let weekStart = CalendarViewModel.shoppingWeekStart(for: day) else {
            return nil
        }
        
        return CalendarViewModel.calendar.startOfDay(for: weekStart)
    }
    
    private func currentShoppingList(for day: Date) -> ShoppingList? {
        if let normalizedStartOfWeek = normalizedStartOfWeek(for: day) {
            return shoppingLists.first {
                CalendarViewModel.calendar.isDate($0.weekStart, inSameDayAs: normalizedStartOfWeek)
            }
        } else { return nil }
    }
    
    private func addIngredientsToShoppingListFor(meal: MealItem, to date: Date) {
        
        guard let normalizedStartOfWeek = normalizedStartOfWeek(for: date) else { return }
        
        let currentShoppingList = currentShoppingList(for: date)
        
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
    
    private func removeIngredientsFromShoppingList(for meal: MealItem, on date: Date) {
        guard let shoppingList = currentShoppingList(for: date) else { return }
        
        for mealIngredient in meal.ingredients {
            let ingredientName = mealIngredient.ingredient.name
            let quatityToRemove = mealIngredient.quantity
            
            guard let shoppingItem = shoppingList.items.first(where: { $0.name == ingredientName}) else { continue }
            
            shoppingItem.quantity -= quatityToRemove
            shoppingList.clearJustAddedFlags()
            
            if shoppingItem.quantity <= 0 {
                if let index = shoppingList.items.firstIndex(where: { $0.persistentModelID == shoppingItem.persistentModelID}) {
                    shoppingList.items.remove(at: index)
                }
                modelContext.delete(shoppingItem)
            }
        }
        
        do { try modelContext.save() } catch { print("Error removing item from shopping list: \(error)")}
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
        plannedMeals: [],
        allGuests: [],
        allGroups: []
    ).frame(width: 400, height: 92)
    
    PlanningMealFrame(
        day: Date(),
        slot: .evening,
        planningViewModel: PlanningViewModel(),
        plannedMeals: [],
        allGuests: [],
        allGroups: []
    ).frame(width: 400, height: 92)
}
