//
//  PlanningView.swift
//  Repascope
//
//  Created by Mickael on 29/04/2026.
//

import SwiftUI

struct OrganizerView: View {
    
    let calendarViewModel = CalendarViewModel()
    @State var weekToDisplay: Date = Date()
    
    var body: some View {
        
        HStack(spacing: 0) {
            
            //MARK: Contenu principal
            VStack (spacing: 0) {
                //MARK: Navigation buttons
                HStack {
                    Button("Semaine précedente") {
                        if let newWeekToDisplay = calendarViewModel.calendar.date(byAdding: .day, value: -7, to: weekToDisplay) {
                            weekToDisplay = newWeekToDisplay
                        }
                    }
                    
                    Button("Cette semaine") {
                        weekToDisplay = Date()
                    }
                    
                    Button("Semaine suivante") {
                        if let newWeekToDisplay = calendarViewModel.calendar.date(byAdding: .day, value: 7, to: weekToDisplay) {
                            weekToDisplay = newWeekToDisplay
                        }
                    }
                }
                
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
                ShoppingList(date: weekToDisplay)
                .frame(minHeight: 100) // hauteur minimale pour éviter l'écrasement
            }
            .padding()
            .frame(width: 300)
        }
        .toolbar {
            Button("Add test data") {
                //
            }
            Button("Delete test data"){
                //
            }
        }
    }
}

#Preview {
    OrganizerView()
}
