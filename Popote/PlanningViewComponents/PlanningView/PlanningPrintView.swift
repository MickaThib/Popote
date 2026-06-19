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
    @Environment(AppSettings.self) private var appSettings
    
    @AppStorage("PlanningFirstDay") private var planningFirstDayRawValue: Int = Weekday.friday.rawValue
    
    let weekToDisplay: Date
    private let printContentWidth: CGFloat = 800
    
    private let calendarViewModel = CalendarViewModel()
    private let planningViewModel = PlanningViewModel()
    
    @Query(sort: \PlannedMeal.date)
    private var allPlannedMeals: [PlannedMeal]
    
    @Query(sort: \Guest.name) private var allGuests: [Guest]
    @Query(sort: \GuestsGroup.title) private var allGroups: [GuestsGroup]
    
    var title: String {
        let startWeekday = Weekday(rawValue: planningFirstDayRawValue) ?? .friday
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "d MMMM yyyy"
        
        if let dateStart = CalendarViewModel.firstDayOfWeek(
            startWeekday: startWeekday,
            from: weekToDisplay
        ) {
            return "Planning de la semaine du \(formatter.string(from: dateStart))"
        } else {
            return "Planning de la semaine"
        }
    }
    
    var body: some View {
        
        VStack(spacing: 6) {
            
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(appSettings.mainColor)
                .padding(.bottom, 36)
            
            HStack {
                Spacer().frame(width: 118)
                
                Text("MIDI")
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(appSettings.mainColorContrast)
                    .font(.system(size: 14, weight: .bold))
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(appSettings.mainColor)
                    )
                
                Text("SOIR")
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(appSettings.mainColorContrast)
                    .font(.system(size: 14, weight: .bold))
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(appSettings.mainColor)
                    )
            }
            
            if let days = calendarViewModel.generateWeek(from: weekToDisplay)?.days {
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
    
    @Environment(AppSettings.self) private var appSettings
    
    let modelContext: ModelContext
    let day: Date
    let planningViewModel:PlanningViewModel
    let calendarViewModel: CalendarViewModel
    let plannedMeals: [PlannedMeal]
    
    let allGuests: [Guest]
    let allGroups: [GuestsGroup]
    
    private let markerWidth: CGFloat = 26
    
    var dayFillColor: Color {
        if CalendarViewModel.isWeekend(day){
            return appSettings.mainColor.opacity(0.2)
        } else {
            return Color.white
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            dayLabel
            
            noonColumn
                .frame(maxWidth: .infinity)
            
            eveningColumn
                .frame(maxWidth: .infinity)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var dayLabel: some View {
        VStack {
            Text(day.formatted(.dateTime.weekday(.wide)))
                .font(.system(size: 14, weight: .bold))
                .textCase(.uppercase)
                .foregroundStyle(appSettings.mainColorContrast)
            
            Text(day.formatted(.dateTime.day().month(.wide)))
                .font(.system(size: 10))
                .foregroundStyle(appSettings.mainColorContrast)
        }
        .frame(width: 110)
        .frame(maxHeight: .infinity)
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .strokeBorder(appSettings.mainColor)
        }
        .background {
            RoundedRectangle(cornerRadius: 5)
                .fill(dayFillColor)
        }
    }

    private var noonColumn: some View {
        HStack(spacing: 8) {
            if calendarViewModel.shouldShowShoppingMarker(before: .noon, on: day) {
                ShoppingMarkerPrintView(moment: calendarViewModel.shoppingMoment)
                    .frame(width: markerWidth)
            }
            
            noonFrame
                .frame(maxWidth: .infinity)
        }
    }

    private var eveningColumn: some View {
        HStack(spacing: 8) {
            if calendarViewModel.shouldShowShoppingMarker(before: .evening, on: day) {
                ShoppingMarkerPrintView(moment: calendarViewModel.shoppingMoment)
                    .frame(width: markerWidth)
            }
            
            eveningFrame
                .frame(maxWidth: .infinity)
            
            if calendarViewModel.shouldShowShoppingMarkerAfterEvening(on: day) {
                ShoppingMarkerPrintView(moment: calendarViewModel.shoppingMoment)
                    .frame(width: markerWidth)
            }
        }
    }
    
    private var noonFrame: some View {
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
    }

    private var eveningFrame: some View {
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
    
    var isDesactivated: Bool {
        plannedMeals.contains { $0.noMealRequired }
    }
    
    var body: some View {
        VStack {
            HStack {
                GuestFieldPrintView(
                    modelContext: modelContext,
                    day: day,
                    slot: slot,
                    plannedMeals: plannedMeals,
                    allGuests: allGuests,
                    allGroups: allGroups
                )
                
                if let pmNotes = plannedMeals.first?.notes, !pmNotes.isEmpty {
                    if !pmNotes.isEmpty {
                        Spacer()
                        Text(pmNotes)
                            .foregroundStyle(isDesactivated ? Color.gray : slot.color())
                            .font(.system(size: 11, weight: .medium))
                    }
                }
                
                
            }
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
                .fill(isDesactivated ? Color.gray.opacity(0.2) : itemColor().opacity(0.2))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .stroke(isDesactivated ? Color.gray : itemColor())
        }
    }
    
    private var emptyMealView: some View {
        HStack(alignment: .firstTextBaseline, spacing: 30) {
            Text(isDesactivated ? "Aucun repas à prévoir" : "Aucun repas prévu")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.gray)
        }
        .padding(.leading, 14)
        .frame(maxWidth: .infinity, minHeight: 60, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .stroke(isDesactivated ? Color.gray : itemColor(), lineWidth: 1)
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
            PlanningPrintMealItem(
                meal: meal,
                slot: plannedMeal.slot,
                deleteAction: {}
            )
            .frame(minHeight: 60, maxHeight: .infinity)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(itemColor(), lineWidth: 2)
            }
        )
    }
    
    func itemColor() -> Color {
        if slot == .noon {
            let settings = UserDefaults.standard.string(forKey: "secondaryColorHex") ?? "#FA8070"
            return Color(displayP3Hex: settings)
        } else {
            let settings = UserDefaults.standard.string(forKey: "mainColorHex") ?? "#6762A4"
            return Color(displayP3Hex: settings)
        }
    }
}

struct PlanningPrintMealItem: View {
    
    @Environment(AppSettings.self) private var appSettings
    
    let meal: MealItem
    let slot: MealSlot
    let deleteAction: () -> Void
    @State private var isHovering: Bool = false
    
    var body: some View {
        HStack {
            Text(meal.title)
                .font(.system(size: 20, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(itemColor())
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white)
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
            return appSettings.secondaryColor
        } else {
            return appSettings.mainColor
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
    
    private var noMealRequired: Bool {
        plannedMeals.contains { $0.noMealRequired }
    }
    
    var body: some View {
        
        HStack(spacing: 6) {
            
            if selectedGuests.isEmpty && selectedGroups.isEmpty {
                Text("Personne")
                    .foregroundStyle(noMealRequired ? Color.gray : slot.color())
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

struct ShoppingMarkerPrintView: View {
    
    let moment: ShoppingMoment
    
    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: "cart.fill")
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(.gray)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 13)
                .fill(Color.gray.opacity(0.12))
        }
    }
}

#Preview {
    PlanningPrintView(weekToDisplay: Date())
}
