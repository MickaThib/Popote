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
    @Query(sort: \ShoppingList.weekStart) private var shoppingLists: [ShoppingList]

    let day: Date
    let slot: MealSlot
    let planningViewModel: PlanningViewModel

    @Query(sort: \MealItem.title) private var meals: [MealItem]
    let plannedMeals: [PlannedMeal]

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

    let allGuests: [Guest]
    let allGroups: [GuestsGroup]

    @State private var isTargeted: Bool = false
    @State private var targetedReplacementID: PersistentIdentifier?
    @State private var showMealPicker = false

    // Largeurs naturelles mesurées par les fantômes
    @State private var chipsNaturalWidth: CGFloat = 0
    @State private var textFieldNaturalWidth: CGFloat = 0

    var body: some View {
        VStack {
            GeometryReader { geo in
                let totalWidth = geo.size.width

                // Le TextField a la priorité : il prend toujours sa largeur naturelle
                // Les chips prennent ce qui reste, avec scroll si nécessaire
                let spacing: CGFloat = 6
                let chipsAllocated = max(0, totalWidth - textFieldNaturalWidth - spacing)
                let shouldScroll   = chipsNaturalWidth > chipsAllocated

                HStack(spacing: spacing) {
                    ConvivesField(
                        day: day,
                        slot: slot,
                        plannedMeals: plannedMeals,
                        allGuests: allGuests,
                        allGroups: allGroups,
                        planningViewModel: planningViewModel,
                        allocatedWidth: chipsAllocated,
                        shouldScroll: shouldScroll,
                        chipsNaturalWidth: $chipsNaturalWidth
                    )

                    Spacer()

                    TextField("Notes", text: notesBinding)
                        .fontWeight(.semibold)
                        .foregroundColor(itemColor())
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.plain)
                        .fixedSize(horizontal: true, vertical: false)
                        // Fantôme de mesure du texte
                        .overlay(alignment: .trailing) {
                            Text(slotNotes.isEmpty ? "Notes" : slotNotes)
                                .fontWeight(.semibold)
                                .fixedSize(horizontal: true, vertical: false)
                                .hidden()
                                .background(
                                    GeometryReader { g in
                                        Color.clear.preference(
                                            key: TextFieldWidthKey.self,
                                            value: g.size.width
                                        )
                                    }
                                )
                        }
                }
            }
            .frame(height: 20)
            .clipped()
            .padding(.horizontal, 7)
            .padding(.top, 7)
            .padding(.bottom, 1)
            .onPreferenceChange(TextFieldWidthKey.self) { w in
                textFieldNaturalWidth = w
            }

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
                .fill(itemColor().opacity(0.3))
        }
    }

    // MARK: - Meal views

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
                meal, date: day, slot: slot,
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
                plannedMeal, to: day, slot: slot,
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
        guard let transfer = transfers.first else { return false }

        switch transfer.kind {
        case .mealItem:
            guard let meal = modelContext.model(for: transfer.persistentID) as? MealItem else {
                print("MealItem introuvable")
                return false
            }
            let oldMeal = targetPlannedMeal.meal
            planningViewModel.replaceMeal(in: targetPlannedMeal, with: meal, modelContext: modelContext)
            if let oldMeal { removeIngredientsFromShoppingList(for: oldMeal, on: day) }
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

    private func normalizedStartOfWeek(for day: Date) -> Date? {
        guard let weekStart = CalendarViewModel.shoppingWeekStart(for: day) else { return nil }
        return CalendarViewModel.calendar.startOfDay(for: weekStart)
    }

    private func currentShoppingList(for day: Date) -> ShoppingList? {
        guard let normalizedStartOfWeek = normalizedStartOfWeek(for: day) else { return nil }
        return shoppingLists.first {
            CalendarViewModel.calendar.isDate($0.weekStart, inSameDayAs: normalizedStartOfWeek)
        }
    }

    private func addIngredientsToShoppingListFor(meal: MealItem, to date: Date) {
        guard let normalizedStartOfWeek = normalizedStartOfWeek(for: date) else { return }

        let shoppingList: ShoppingList
        if let existing = currentShoppingList(for: date) {
            shoppingList = existing
            shoppingList.items.forEach { $0.justAdded = false }
        } else {
            shoppingList = ShoppingList(weekStart: normalizedStartOfWeek)
            modelContext.insert(shoppingList)
        }

        for ingredient in meal.ingredients {
            if let existingItem = shoppingList.items.first(where: { $0.name == ingredient.ingredient.name }) {
                existingItem.quantity += ingredient.quantity
                existingItem.justAdded = true
            } else {
                shoppingList.items.append(ShoppingItem(
                    name: ingredient.ingredient.name,
                    quantity: ingredient.quantity,
                    justAdded: true
                ))
            }
        }

        do { try modelContext.save() } catch { print("Error: \(error)") }
    }

    private func removeIngredientsFromShoppingList(for meal: MealItem, on date: Date) {
        guard let shoppingList = currentShoppingList(for: date) else { return }

        for mealIngredient in meal.ingredients {
            let name = mealIngredient.ingredient.name
            guard let item = shoppingList.items.first(where: { $0.name == name }) else { continue }

            item.quantity -= mealIngredient.quantity
            shoppingList.clearJustAddedFlags()

            if item.quantity <= 0 {
                if let index = shoppingList.items.firstIndex(where: { $0.persistentModelID == item.persistentModelID }) {
                    shoppingList.items.remove(at: index)
                }
                modelContext.delete(item)
            }
        }

        do { try modelContext.save() } catch { print("Error removing item: \(error)") }
    }

    // MARK: - Helpers

    private func mealPickerPopover() -> some View {
        MealPickerPopover(meals: meals) { selectedMeal in
            planningViewModel.setPlannedMeal(
                selectedMeal, date: day, slot: slot,
                existingPlannedMeals: plannedMeals,
                modelContext: modelContext
            )
            addIngredientsToShoppingListFor(meal: selectedMeal, to: day)
            showMealPicker = false
        }
    }

    func itemColor() -> Color {
        slot == .noon ? Color.noon : Color.evening
    }
}

// MARK: - PreferenceKey

private struct TextFieldWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Preview

#Preview {
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
