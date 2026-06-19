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
    @Environment(AppSettings.self) private var appSettings

    @Query(sort: \ShoppingList.weekStart) private var shoppingLists: [ShoppingList]
    @Query(sort: \MealItem.title) private var meals: [MealItem]

    let day: Date
    let slot: MealSlot
    let planningViewModel: PlanningViewModel
    let calendarViewModel: CalendarViewModel
    let plannedMeals: [PlannedMeal]

    let allGuests: [Guest]
    let allGroups: [GuestsGroup]

    @State private var isTargeted: Bool = false
    @State private var targetedReplacementID: PersistentIdentifier?
    @State private var showMealPicker = false

    private var plannedMealsWithMeal: [PlannedMeal] {
        plannedMeals.filter { $0.meal != nil }
    }

    private var slotNotes: String {
        plannedMeals.first?.notes ?? ""
    }

    private var notesBinding: Binding<String> {
        Binding(
            get: { slotNotes },
            set: { newValue in
                planningViewModel.updateNotes(
                    newValue,
                    date: day,
                    slot: slot,
                    existingPlannedMeals: plannedMeals,
                    modelContext: modelContext
                )
            }
        )
    }

    var isDesactivated: Bool {
        plannedMeals.contains { $0.noMealRequired }
    }

    var body: some View {
        VStack {
                HStack(spacing: 6) {
                    ConvivesField(
                        day: day,
                        slot: slot,
                        plannedMeals: plannedMeals,
                        allGuests: allGuests,
                        allGroups: allGroups,
                        planningViewModel: planningViewModel,
                        markNoMealRequiredAction: {
                            markNoMealRequired()
                        }
                    )
                    
                    Divider()
                    
                    notesTextField
                }
                .frame(height: 20)
                .padding(.horizontal, 7)
                .padding(.top, 7)
                .padding(.bottom, 1)
                
                if plannedMealsWithMeal.isEmpty {
                    emptyMealView
                        .padding(.horizontal, 7)
                        .padding(.bottom, 7)
                } else if plannedMealsWithMeal.count == 1 {
                    singleMealView
                        .padding(.horizontal, 7)
                        .padding(.bottom, 7)
                } else {
                    multipleMealsView
                        .padding(.horizontal, 7)
                        .padding(.bottom, 7)
                }
            }
            .frame(minWidth: 150, maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .fill(isDesactivated ? .gray.opacity(0.5) : itemColor().opacity(0.3))
            }
    }

    // MARK: - Custom TextField

    private var notesTextField: some View {
        ZStack(alignment: .trailing) {
            if notesBinding.wrappedValue.isEmpty {
                Text("Notes")
                    .foregroundStyle(isDesactivated ? .white : itemColor())
                    .opacity(0.7)
            }

            TextField("", text: notesBinding)
                .fontWeight(.semibold)
                .foregroundColor(isDesactivated ? .white : itemColor())
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.plain)
                .frame(width: 90)
                .fixedSize(horizontal: true, vertical: false)
        }
    }

    // MARK: - Meal views

    private var emptyMealView: some View {
        HStack(alignment: .firstTextBaseline, spacing: 30) {
            Text(isDesactivated ? "Aucun repas à prévoir" : "Aucun repas prévu")
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
                    .stroke(itemColor(), lineWidth: isTargeted ? 2 : 1)
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

    private func markNoMealRequired() {
        for plannedMeal in plannedMealsWithMeal {
            if let meal = plannedMeal.meal {
                removeIngredientsFromShoppingList(for: meal, date: day, slot: slot)
            }
        }

        planningViewModel.markNoMealRequired(
            date: day,
            slot: slot,
            existingPlannedMeals: plannedMeals,
            modelContext: modelContext
        )
    }

    // MARK: - Drop handling

    private func handlePlanningDrop(_ transfers: [PlanningDropTransfer]) -> Bool {
        guard let transfer = transfers.first else { return false }

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

            addIngredientsToShoppingListFor(meal: meal, date: day, slot: slot)
            return true

        case .plannedMeal:
            guard let plannedMeal = modelContext.model(for: transfer.persistentID) as? PlannedMeal else {
                print("🔴 PlannedMeal introuvable")
                return false
            }

            let oldDate = plannedMeal.date
            let oldSlot = plannedMeal.slot
            let movedMeal = plannedMeal.meal

            if let movedMeal {
                removeIngredientsFromShoppingList(for: movedMeal, date: oldDate, slot: oldSlot)
            }

            planningViewModel.movePlannedMeal(
                plannedMeal,
                to: day,
                slot: slot,
                plannedMealsForDestinationSlot: plannedMeals,
                modelContext: modelContext
            )

            if let movedMeal {
                addIngredientsToShoppingListFor(meal: movedMeal, date: day, slot: slot)
            }

            return true
        }
    }

    private func handleReplacementDrop(
        _ transfers: [PlanningDropTransfer],
        replacing targetPlannedMeal: PlannedMeal
    ) -> Bool {
        guard let transfer = transfers.first else { return false }

        switch transfer.kind {
        case .mealItem:
            guard let meal = modelContext.model(for: transfer.persistentID) as? MealItem else {
                print("MealItem introuvable")
                return false
            }

            let oldMeal = targetPlannedMeal.meal

            if let oldMeal {
                removeIngredientsFromShoppingList(for: oldMeal, date: day, slot: slot)
            }

            planningViewModel.replaceMeal(
                in: targetPlannedMeal,
                with: meal,
                modelContext: modelContext
            )

            addIngredientsToShoppingListFor(meal: meal, date: day, slot: slot)
            return true

        case .plannedMeal:
            guard let sourcePlannedMeal = modelContext.model(for: transfer.persistentID) as? PlannedMeal else {
                print("PlannedMeal introuvable")
                return false
            }

            let sourceDate = sourcePlannedMeal.date
            let sourceSlot = sourcePlannedMeal.slot
            let sourceMeal = sourcePlannedMeal.meal

            let targetDate = targetPlannedMeal.date
            let targetSlot = targetPlannedMeal.slot
            let targetMeal = targetPlannedMeal.meal

            if let sourceMeal {
                removeIngredientsFromShoppingList(for: sourceMeal, date: sourceDate, slot: sourceSlot)
            }

            if let targetMeal {
                removeIngredientsFromShoppingList(for: targetMeal, date: targetDate, slot: targetSlot)
            }

            planningViewModel.swapPlannedMeals(
                sourcePlannedMeal,
                with: targetPlannedMeal,
                modelContext: modelContext
            )

            if let sourceMeal {
                addIngredientsToShoppingListFor(meal: sourceMeal, date: targetDate, slot: targetSlot)
            }

            if let targetMeal {
                addIngredientsToShoppingListFor(meal: targetMeal, date: sourceDate, slot: sourceSlot)
            }

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

                    if let deletedMeal {
                        removeIngredientsFromShoppingList(for: deletedMeal, date: day, slot: slot)
                    }
                },
                isTargetedForReplacement: targetedReplacementID == plannedMeal.persistentModelID
            )
            .frame(minHeight: 40, maxHeight: .infinity)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(
                        targetedReplacementID == plannedMeal.persistentModelID ? itemColor() : Color.clear,
                        lineWidth: 2
                    )
            }
            .draggable(PlanningDropTransfer(persistentID: plannedMeal.persistentModelID, kind: .plannedMeal)) {
                Text(plannedMeal.meal?.title ?? "Repas")
                    .foregroundStyle(itemColor())
                    .fontWeight(.bold)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 50)
                    .frame(height: 40)
                    .background(.white, in: RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(itemColor(), lineWidth: 2))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .opacity(0.5)
            }
            .dropDestination(for: PlanningDropTransfer.self) { transfers, _ in
                handleReplacementDrop(transfers, replacing: plannedMeal)
            } isTargeted: { targeted in
                if targeted {
                    targetedReplacementID = plannedMeal.persistentModelID
                } else if targetedReplacementID == plannedMeal.persistentModelID {
                    targetedReplacementID = nil
                }
            }
        )
    }

    // MARK: - Shopping list

    private func shoppingListStart(for date: Date, slot: MealSlot) -> Date? {
        calendarViewModel.shoppingListStart(forMealDate: date, slot: slot)
    }

    private func currentShoppingList(for date: Date, slot: MealSlot) -> ShoppingList? {
        guard let shoppingListStart = shoppingListStart(for: date, slot: slot) else {
            return nil
        }

        return shoppingLists.first {
            CalendarViewModel.calendar.isDate($0.weekStart, inSameDayAs: shoppingListStart)
        }
    }

    private func addIngredientsToShoppingListFor(meal: MealItem, date: Date, slot: MealSlot) {
        guard let shoppingListStart = shoppingListStart(for: date, slot: slot) else {
            return
        }

        let shoppingList: ShoppingList

        if let existing = currentShoppingList(for: date, slot: slot) {
            shoppingList = existing
            shoppingList.items.forEach { $0.justAdded = false }
        } else {
            shoppingList = ShoppingList(weekStart: shoppingListStart)
            modelContext.insert(shoppingList)
        }

        for ingredient in meal.ingredients {
            if let existingItem = shoppingList.items.first(where: { $0.name == ingredient.ingredient.name }) {
                existingItem.quantity += ingredient.quantity
                existingItem.justAdded = true
            } else {
                shoppingList.items.append(
                    ShoppingItem(
                        name: ingredient.ingredient.name,
                        quantity: ingredient.quantity,
                        justAdded: true
                    )
                )
            }
        }

        do {
            try modelContext.save()
        } catch {
            print("Error adding shopping items: \(error)")
        }
    }

    private func removeIngredientsFromShoppingList(for meal: MealItem, date: Date, slot: MealSlot) {
        guard let shoppingList = currentShoppingList(for: date, slot: slot) else {
            return
        }

        shoppingList.clearJustAddedFlags()

        for mealIngredient in meal.ingredients {
            let name = mealIngredient.ingredient.name

            guard let item = shoppingList.items.first(where: { $0.name == name }) else {
                continue
            }

            item.quantity -= mealIngredient.quantity

            if item.quantity <= 0 {
                if let index = shoppingList.items.firstIndex(where: { $0.persistentModelID == item.persistentModelID }) {
                    shoppingList.items.remove(at: index)
                }
                modelContext.delete(item)
            }
        }

        do {
            try modelContext.save()
        } catch {
            print("Error removing shopping items: \(error)")
        }
    }

    // MARK: - Helpers

    private func mealPickerPopover() -> some View {
        MealPickerPopover(meals: meals) { selectedMeal in
            planningViewModel.setPlannedMeal(
                selectedMeal,
                date: day,
                slot: slot,
                existingPlannedMeals: plannedMeals,
                modelContext: modelContext
            )

            addIngredientsToShoppingListFor(meal: selectedMeal, date: day, slot: slot)
            showMealPicker = false
        }
    }

    func itemColor() -> Color {
        slot == .noon ? appSettings.secondaryColor : appSettings.mainColor
    }
}

// MARK: - Preview

#Preview {
    PlanningMealFrame(
        day: Date(),
        slot: .noon,
        planningViewModel: PlanningViewModel(),
        calendarViewModel: CalendarViewModel(),
        plannedMeals: [],
        allGuests: [],
        allGroups: []
    )
    .frame(width: 400, height: 92)
    .environment(AppSettings())

    PlanningMealFrame(
        day: Date(),
        slot: .evening,
        planningViewModel: PlanningViewModel(),
        calendarViewModel: CalendarViewModel(),
        plannedMeals: [],
        allGuests: [],
        allGroups: []
    )
    .frame(width: 400, height: 92)
    .environment(AppSettings())
}
