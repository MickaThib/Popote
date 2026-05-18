//
//  PlanningView.swift
//  Repascope
//
//  Created by Mickael on 29/04/2026.
//

import SwiftUI
import SwiftData

struct OrganizerView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    let calendarViewModel = CalendarViewModel()
    @State var weekToDisplay: Date = Date()
    
    // Pour test uniquement
    @State private var testPlannedMeals: [PlannedMeal] = []
    @State private var testMealItems: [MealItem] = []
        
    var body: some View {
        
        HStack(spacing: 0) {
            
            //MARK: Contenu principal
            VStack (spacing: 0) {
                //MARK: Navigation buttons
                HStack(spacing: 30) {
                    Button {
                        if let newWeekToDisplay = calendarViewModel.calendar.date(byAdding: .day, value: -7, to: weekToDisplay) {
                            weekToDisplay = newWeekToDisplay
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        weekToDisplay = Date()
                    } label: {
                        Text("Cette semaine")
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        if let newWeekToDisplay = calendarViewModel.calendar.date(byAdding: .day, value: 7, to: weekToDisplay) {
                            weekToDisplay = newWeekToDisplay
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 10)
                
                PlanningView(weekToDisplay: weekToDisplay)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)

            }
            .padding(.top, 20)
            .padding(.horizontal, 40)
            
            //MARK: Volet droit
            VSplitView {
                
                //Section haute
                MealList()
                .frame(minHeight: 100) // hauteur minimale pour éviter l'écrasement
                                
                //Section basse
                ShoppingListView(date: weekToDisplay)
                .frame(minHeight: 100) // hauteur minimale pour éviter l'écrasement
            }
            .padding()
            .frame(width: 300)
        }
    }
}

#Preview {
    OrganizerView()
}
