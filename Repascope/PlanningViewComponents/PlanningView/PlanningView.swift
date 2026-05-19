//
//  PlanningViewComponent.swift
//  Repascope
//
//  Created by Mickael Thibouret on 30/04/2026.
//

import SwiftUI
import SwiftData

struct PlanningView: View {
    
    let weekToDisplay: Date
    
    private let calendarViewModel = CalendarViewModel()
    private let planningViewModel = PlanningViewModel()
    
    @Query(sort: \PlannedMeal.date)
    private var allPlannedMeals: [PlannedMeal]

    var body: some View {
        
        ScrollView {
            if let days = calendarViewModel.generateWeek(
                from: weekToDisplay,
                firstDay: .friday
            )?.days {
                ForEach(days, id: \.self) { day in
                    PlanningLine(
                        day: day,
                        viewModel: planningViewModel,
                        plannedMeals: allPlannedMeals
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
    }
}

#Preview {
    PlanningView(weekToDisplay: Date())
}
