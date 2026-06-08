//
//  PlanningPrintView.swift
//  Popote
//
//  Created by Mickael on 05/06/2026.
//

import SwiftUI
import SwiftData

struct PlanningPrintView: View {
    
    @Environment(\.modelContext) private var modelContext

    let weekToDisplay: Date
    private let printContentWidth: CGFloat = 900
    
    private let calendarViewModel = CalendarViewModel()
    private let planningViewModel = PlanningViewModel()
    
    @Query(sort: \PlannedMeal.date)
    private var allPlannedMeals: [PlannedMeal]
    
    @Query(sort: \Guest.name) private var allGuests: [Guest]
    @Query(sort: \GuestsGroup.title) private var allGroups: [GuestsGroup]
    
    var body: some View {
                
        VStack(spacing: 6) {
            HStack {
                Spacer().frame(width: 158)
                
                Text("MIDI")
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color.themeContrast)
                    .font(.system(size: 14, weight: .bold))
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.theme)
                    )
                
                Text("SOIR")
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color.themeContrast)
                    .font(.system(size: 14, weight: .bold))
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.theme)
                    )
            }
            
            if let days = calendarViewModel.generateWeek(
                from: weekToDisplay,
                firstDay: .friday
            )?.days {
                ForEach(days, id: \.self) { day in
                    PlanningLinePrintView(
                        modelContext: modelContext,
                        day: day,
                        planningViewModel: planningViewModel,
                        calendarViewModel: calendarViewModel,
                        plannedMeals: allPlannedMeals,
                        allGuests: allGuests,
                        allGroups: allGroups
                    )
                    .frame(maxHeight: .infinity)
                }
            }
        }
        .frame(width: printContentWidth)
        .frame(maxHeight: .infinity)
    }
}

struct PlanningLinePrintView: View {
    
    let modelContext: ModelContext
    let day: Date
    let planningViewModel:PlanningViewModel
    let calendarViewModel: CalendarViewModel
    let plannedMeals: [PlannedMeal]
    
    let allGuests: [Guest]
    let allGroups: [GuestsGroup]
    
    let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "fr_FR")
        cal.firstWeekday = 2
        return cal
    }()
    
    var dayFillColor: Color {
        if CalendarViewModel.isWeekend(day){
            return Color.theme.opacity(0.2)
        } else {
            return Color.white
        }
    }
    
    var body: some View {
        HStack {
            VStack {
                Text(day.formatted(.dateTime.weekday(.wide)))
                    .font(.system(size: 14, weight: .bold))
                    .textCase(.uppercase)
                    .foregroundStyle(Color.themeContrast)
                Text(day.formatted(.dateTime.day().month(.wide)))
                    .font(.system(size: 10))
                    .foregroundStyle(Color.themeContrast)
            }
            .frame(width: 150)
            .frame(maxHeight: .infinity)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(Color.theme)
            }
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(dayFillColor)
            )
            
            
            PlanningPrintFrameView(
                modelContext: modelContext,
                day: day,
                slot: .noon,
                planningViewModel: planningViewModel,
                plannedMeals: planningViewModel.planned(
                    for: day,
                    slot: .noon,
                    in: plannedMeals
                ),
                allGuests: allGuests,
                allGroups: allGroups
            )
            
            PlanningPrintFrameView(
                modelContext: modelContext,
                day: day,
                slot: .evening,
                planningViewModel: planningViewModel,
                plannedMeals: planningViewModel.planned(
                    for: day,
                    slot: .evening,
                    in: plannedMeals
                ),
                allGuests: allGuests,
                allGroups: allGroups
            )
        }
        .frame(maxHeight: .infinity)
    }
    
    struct PlanningPrintFrameView: View {
        
        let modelContext:ModelContext
        
        let day: Date
        let slot: MealSlot
        let planningViewModel:PlanningViewModel
        let plannedMeals:[PlannedMeal]
        private var plannedMealsWithMeal: [PlannedMeal] {
            plannedMeals.filter { $0.meal != nil }
        }
        
        let allGuests: [Guest]
        let allGroups: [GuestsGroup]
                
        var body: some View {
            VStack {
                GuestFieldPrintView(
                    modelContext: modelContext,
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
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(itemColor().opacity(0.2))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(itemColor())
            }
        }
        
        private var emptyMealView: some View {
            HStack(alignment: .firstTextBaseline, spacing: 30) {
                Text("Aucun repas prévu")
                    .font(.callout)
                    .foregroundStyle(.gray)
            }
            .padding(.leading, 14)
            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(itemColor(), lineWidth: 1)
            }
        }
        
        private var singleMealView: some View {
            HStack {
                if let plannedMeal = plannedMealsWithMeal.first {
                    replaceableMealItem(for: plannedMeal)
                }
            }
        }
        
        private var multipleMealsView: some View {
            HStack {
                ForEach(plannedMealsWithMeal) { plannedMeal in
                    replaceableMealItem(for: plannedMeal)
                }
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
                    deleteAction: {},
                    isTargetedForReplacement: false
                )
                .frame(minHeight: 40, maxHeight: .infinity)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(itemColor(), lineWidth: 2)
                }
            )
        }
        
        func itemColor() -> Color {
            if slot == .noon {
                return Color.noon
            } else {
                return Color.evening
            }
        }
    }
}

struct GuestFieldPrintView: View {
    let modelContext: ModelContext
    
    let day: Date
    let slot: MealSlot
    let plannedMeals: [PlannedMeal]
    let allGuests: [Guest]
    let allGroups: [GuestsGroup]
    
    private var selectedGuests: [Guest] {
        unique(plannedMeals.flatMap(\.guests))
    }
    
    private var selectedGroups: [GuestsGroup] {
        unique(plannedMeals.flatMap(\.guestsGroups))
    }
    
    var body: some View {
        
        HStack(spacing: 6) {
            
            if selectedGuests.isEmpty && selectedGroups.isEmpty {
                Text("Personne")
                    .foregroundStyle(slot.color())
                    .font(.system(size: 11, weight: .medium))
                    .textCase(.uppercase)
            }
            
            ForEach(selectedGuests) { guest in
                ChipPrintView(title: guest.name, color: Color(displayP3Hex: guest.colorHex))
            }
            
            ForEach(selectedGroups) { group in
                ChipPrintView(title: group.title, color: Color(displayP3Hex: group.colorHex))
            }
            Spacer()
        }
        .frame(height: 20)
    }
    
    private func unique<T: PersistentModel>(_ items: [T]) -> [T] {
        var seen = Set<PersistentIdentifier>()
        
        return items.filter { item in
            seen.insert(item.persistentModelID).inserted
        }
    }
}

struct ChipPrintView: View {
    
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .medium))
            .textCase(.uppercase)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .frame(height: 20)
            .fixedSize(horizontal: true, vertical: false)
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .fill(color.mix(with: .white, by: 0.8))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(color, lineWidth: 1)
            }
    }
}

#Preview {
    PlanningPrintView(weekToDisplay: Date())
}
