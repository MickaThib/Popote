//
//  PlanningViewModel.swift
//  Repascope
//
//  Created by Mickael on 15/05/2026.
//

import Foundation
import SwiftData

@MainActor
final class PlanningViewModel {
    
    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "fr_FR")
        cal.firstWeekday = 2
        return cal
    }()
    
    func planned(for date: Date, slot: MealSlot, in plannedMeals: [PlannedMeal]) -> [PlannedMeal] {
        let day = calendar.startOfDay(for: date)
        
        return plannedMeals
            .filter { plannedMeal in
                calendar.isDate(plannedMeal.date, inSameDayAs: day)
                && plannedMeal.slot == slot
            }
            .sorted { $0.position < $1.position }
    }
    
    func delete(plannedMeal: PlannedMeal?, plannedMealsForSlot: [PlannedMeal], modelContext: ModelContext) {
        guard let plannedMeal else {
            return
        }
        
        modelContext.delete(plannedMeal)
        
        let remainingMeals = plannedMealsForSlot
            .filter { $0.persistentModelID != plannedMeal.persistentModelID }
            .sorted { $0.position < $1.position }
        
        for (index, meal) in remainingMeals.enumerated() {
            meal.position = index
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error deleting plannedMeal : \(plannedMeal.meal?.title ?? "Unknown")")
            print(error)
        }
    }
    
    func setPlannedMeal(_ meal: MealItem, date: Date, slot: MealSlot, existingPlannedMeals: [PlannedMeal], modelContext: ModelContext) {
        
        let mealsForSlot = planned(for: date, slot: slot, in: existingPlannedMeals)
        
        guard mealsForSlot.count < 2 else {
            print("Il y a déjà deux repas pour ce créneau.")
            return
        }
        
        let day = calendar.startOfDay(for: date)
        
        let plannedMeal = PlannedMeal(
            date: day,
            slot: slot,
            position: mealsForSlot.count,
            meal: meal
        )
        
        modelContext.insert(plannedMeal)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving plannedMeal")
            print(error)
        }
    }
    
    func replaceMeal(in plannedMeal:PlannedMeal, with newMeal:MealItem, modelContext:ModelContext) {
        
        plannedMeal.meal = newMeal
        
        do {
            try modelContext.save()
        } catch {
            print("Error replacing plannedMeal")
            print(error)
        }
    }
    
    func movePlannedMeal(_ plannedMeal: PlannedMeal, to date: Date, slot: MealSlot, plannedMealsForDestinationSlot: [PlannedMeal], modelContext: ModelContext) {
        
        // Eviter le drop sur la source
        let day = calendar.startOfDay(for: date)
        
        let isSameDay = calendar.isDate(plannedMeal.date, inSameDayAs: day)
        let isSameSlot = plannedMeal.slot == slot
        
        if isSameDay && isSameSlot {
            return
        }
        // --
        
        let destinationMeals = plannedMealsForDestinationSlot.filter {
            $0.persistentModelID != plannedMeal.persistentModelID
        }
        
        guard destinationMeals.count < 2 else {
            // TODO: Alert
            print("Le créneau de destination contient déjà deux repas")
            return
        }
        
        plannedMeal.date = calendar.startOfDay(for: date)
        plannedMeal.slot = slot
        plannedMeal.position = destinationMeals.count
        
        
        do {
            try modelContext.save()
        } catch {
            print("Error moving plannedMeal")
            print(error)
        }
    }
    
    func swapPlannedMeals(_ source: PlannedMeal, with target: PlannedMeal, modelContext:ModelContext) {
        
        guard source.persistentModelID != target.persistentModelID else {
            return
        }
        
        let sourceDate = source.date
        let sourceSlot = source.slot
        let sourcePosition = source.position
        
        source.date = target.date
        source.slot = target.slot
        source.position = target.position
        
        target.date = sourceDate
        target.slot = sourceSlot
        target.position = sourcePosition
        
        do {
            try modelContext.save()
        } catch {
            print("Erreur de swap")
            print(error)
        }
    }
}
