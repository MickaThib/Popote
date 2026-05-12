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
    
    let calendar: Calendar = {
            var cal = Calendar(identifier: .gregorian)
            cal.locale = Locale(identifier: "fr_FR")
            cal.firstWeekday = 2
            return cal
        }()
    
    var isToday: Bool { calendar.isDateInToday(day) }
    
    @Environment(\.modelContext) private var context
    @Query private var allPlanned:[PlannedMeal]
    
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
                    .stroke(isToday ? Color.accentColor : Color.gray)
            }
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(isToday ? Color.accentColor.opacity(0.1) : Color.clear)
            )
            
            
            PlanningMealFrame(day: day, slot: .noon, plannedMeals: planned(for: day, slot: .noon))

            PlanningMealFrame(day: day, slot: .evening, plannedMeals: planned(for: day, slot: .evening))

        }
        .frame(height: 80)
        .padding(1)
    }
    
    private func planned(for date: Date, slot: MealSlot) -> [PlannedMeal] {
        let day = Calendar.current.startOfDay(for: date)
        return allPlanned
            .filter {$0.date == day && $0.slot == slot}
            .sorted {$0.position < $1.position}
    }
}

#Preview {
    PlanningLine(day: Date())
}
