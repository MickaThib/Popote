//
//  PlanningLine.swift
//  Repascope
//
//  Created by Mickael Thibouret on 30/04/2026.
//

import SwiftUI
import SwiftData

struct PlanningLine: View {
    
    let day: Date
    let viewModel:PlanningViewModel
    let plannedMeals: [PlannedMeal]
    
    let calendar: Calendar = {
            var cal = Calendar(identifier: .gregorian)
            cal.locale = Locale(identifier: "fr_FR")
            cal.firstWeekday = 2
            return cal
        }()
    
    var isToday: Bool { calendar.isDateInToday(day) }
    
    
    var body: some View {
        HStack {
            VStack {
                Text(day.formatted(.dateTime.weekday(.wide)))
                    .font(.system(size: 14, weight: .bold))
                    .textCase(.uppercase)
                    .foregroundStyle(isToday ? Color.accentColor : Color.primary)
                Text(day.formatted(.dateTime.day().month(.wide)))
                    .font(.system(size: 10))
                    .foregroundStyle(isToday ? Color.accentColor : Color.primary)
            }
            .frame(width: 150)
            .frame(maxHeight: .infinity)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(isToday ? Color.accentColor : Color.clear)
            }
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(isToday ? Color.accentColor.opacity(0.25) : Color.accentColor.opacity(0.15))
            )
            
            
            PlanningMealFrame(
                day: day,
                slot: .noon,
                viewModel: viewModel,
                plannedMeals: viewModel.planned(
                    for: day,
                    slot: .noon,
                    in: plannedMeals
                )
            )

            PlanningMealFrame(
                day: day,
                slot: .evening,
                viewModel: viewModel,
                plannedMeals: viewModel.planned(
                    for: day,
                    slot: .evening,
                    in: plannedMeals
                )
            )

        }
        .frame(height: 80)
        .padding(1)
    }
    
    
}

#Preview {
    PlanningLine(day: Date(), viewModel: PlanningViewModel(), plannedMeals: [])
}
