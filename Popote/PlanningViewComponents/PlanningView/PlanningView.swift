//
//  PlanningViewComponent.swift
//  Popote
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
    
    @Query(sort: \Guest.name) private var allGuests: [Guest]
    @Query(sort: \GuestsGroup.title) private var allGroups: [GuestsGroup]

    var body: some View {
        
        ScrollView {
            
            HStack {
                Spacer().frame(width: 158)
                
                Text("MIDI")
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color.themeContrast)
                    .font(.system(size: 14, weight: .bold))
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.theme.opacity(0.1))
                    )

                Text("SOIR")
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color.themeContrast)
                    .font(.system(size: 14, weight: .bold))
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.theme.opacity(0.1))
                    )
            }
            .padding(.vertical, 0)
            
            if let days = calendarViewModel.generateWeek(
                from: weekToDisplay,
                firstDay: .friday
            )?.days {
                ForEach(days, id: \.self) { day in
                    PlanningLine(
                        day: day,
                        planningViewModel: planningViewModel,
                        calendarViewModel: calendarViewModel,
                        plannedMeals: allPlannedMeals,
                        allGuests: allGuests,
                        allGroups: allGroups
                    )
                }
            }
        }
        .padding()
    }
}

#Preview {
    PlanningView(weekToDisplay: Date())
}
