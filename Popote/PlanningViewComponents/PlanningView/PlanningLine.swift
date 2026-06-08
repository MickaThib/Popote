//
//  PlanningLine.swift
//  Popote
//
//  Created by Mickael Thibouret on 30/04/2026.
//

import SwiftUI
import SwiftData

struct PlanningLine: View {
    
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
    
    var isToday: Bool { calendar.isDateInToday(day) }
    
    var dayStrokeColor: Color {
        if isToday {
            return Color.theme
        } else if CalendarViewModel.isWeekend(day){
            return Color.theme.opacity(0.2)
        } else {
            return Color.clear
        }
    }
    
    var dayFillColor: Color {
        if CalendarViewModel.isWeekend(day){
            return Color.white
        } else {
            return Color.theme
        }
    }
    
    var dayTextColor: Color {
        if isToday {
            return Color.theme
        } else if CalendarViewModel.isWeekend(day){
            return Color.themeContrast
        } else {
            return Color.themeContrast
        }
    }
    
    
    var body: some View {
        HStack {
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
            
            
            PlanningMealFrame(
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

            PlanningMealFrame(
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
        .frame(height: 82)
        .padding(1)
    }
    
    
}

#Preview {
    PlanningLine(day: Date(),
                 planningViewModel: PlanningViewModel(),
                 calendarViewModel: CalendarViewModel(),
                 plannedMeals: [],
                 allGuests: [],
                 allGroups: []
    )
}
