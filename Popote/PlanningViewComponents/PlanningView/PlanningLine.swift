//
//  PlanningLine.swift
//  Popote
//
//  Created by Mickael Thibouret on 30/04/2026.
//

import SwiftUI

struct PlanningLine: View {
    
    @Environment(AppSettings.self) private var appSettings
    
    let day: Date
    let planningViewModel: PlanningViewModel
    let calendarViewModel: CalendarViewModel
    let plannedMeals: [PlannedMeal]
    
    let allGuests: [Guest]
    let allGroups: [GuestsGroup]
    
    var isToday: Bool {
        CalendarViewModel.calendar.isDateInToday(day)
    }
    
    var dayStrokeColor: Color {
        if isToday {
            return appSettings.mainColor
        } else if CalendarViewModel.isWeekend(day) {
            return appSettings.mainColor.opacity(0.2)
        } else {
            return Color.clear
        }
    }
    
    var dayFillColor: Color {
        if CalendarViewModel.isWeekend(day) {
            return Color.white
        } else {
            return appSettings.mainColor
        }
    }
    
    var dayTextColor: Color {
        if isToday {
            return appSettings.mainColor
        } else if CalendarViewModel.isWeekend(day) {
            return appSettings.mainColorContrast
        } else {
            return appSettings.mainColorContrast
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
        .frame(height: 82)
        .padding(1)
    }
    
    private var dayLabel: some View {
        VStack {
            Text(day.formatted(.dateTime.weekday(.wide)))
                .font(.system(size: 14, weight: .bold))
                .textCase(.uppercase)
                .foregroundStyle(dayTextColor)
            
            Text(day.formatted(.dateTime.day().month(.wide)))
                .font(.system(size: 10))
                .foregroundStyle(dayTextColor)
        }
        .frame(width: 150)
        .frame(maxHeight: .infinity)
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .strokeBorder(dayStrokeColor)
        }
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(dayFillColor)
                .opacity(isToday ? 0.2 : 0.1)
        )
    }
    
    private var noonColumn: some View {
        HStack(spacing: 8) {
            if calendarViewModel.shouldShowShoppingMarker(before: .noon, on: day) {
                ShoppingMarkerView(moment: calendarViewModel.shoppingMoment)
            }

            noonMealFrame
                .frame(maxWidth: .infinity)
        }
    }

    private var eveningColumn: some View {
        HStack(spacing: 8) {
            if calendarViewModel.shouldShowShoppingMarker(before: .evening, on: day) {
                ShoppingMarkerView(moment: calendarViewModel.shoppingMoment)
            }

            eveningMealFrame
                .frame(maxWidth: .infinity)

            if calendarViewModel.shouldShowShoppingMarkerAfterEvening(on: day) {
                ShoppingMarkerView(moment: calendarViewModel.shoppingMoment)
            }
        }
    }
    
    private var noonMealFrame: some View {
        PlanningMealFrame(
            day: day,
            slot: .noon,
            planningViewModel: planningViewModel,
            calendarViewModel: calendarViewModel,
            plannedMeals: planningViewModel.planned(
                for: day,
                slot: .noon,
                in: plannedMeals
            ),
            allGuests: allGuests,
            allGroups: allGroups
        )
    }

    private var eveningMealFrame: some View {
        PlanningMealFrame(
            day: day,
            slot: .evening,
            planningViewModel: planningViewModel,
            calendarViewModel: calendarViewModel,
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

#Preview {
    PlanningLine(
        day: Date(),
        planningViewModel: PlanningViewModel(),
        calendarViewModel: CalendarViewModel(),
        plannedMeals: [],
        allGuests: [],
        allGroups: []
    )
    .environment(AppSettings())
}
