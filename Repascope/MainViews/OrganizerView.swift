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
        
        HStack(spacing: 20) {
            
            //MARK: Contenu principal
            VStack (spacing: 0) {
                //MARK: Navigation buttons
                HStack {
                    Button {
                        if let newWeekToDisplay = calendarViewModel.calendar.date(byAdding: .day, value: -7, to: weekToDisplay) {
                            weekToDisplay = newWeekToDisplay
                        }
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Précédente")
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Button {
                        weekToDisplay = Date()
                    } label: {
                        Text("Cette semaine")
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button {
                        if let newWeekToDisplay = calendarViewModel.calendar.date(byAdding: .day, value: 7, to: weekToDisplay) {
                            weekToDisplay = newWeekToDisplay
                        }
                    } label: {
                        HStack {
                            Text("Suivante")
                            Image(systemName: "chevron.right")
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                PlanningView(weekToDisplay: weekToDisplay)
                    .frame(maxWidth: .infinity)
            }
            
            //MARK: Volet droit
            VSplitView {
                
                //Section haute
                MealList()
                .frame(minHeight: 100) // hauteur minimale pour éviter l'écrasement
                                
                //Section basse
                ShoppingListView(date: weekToDisplay)
                .frame(minHeight: 100) // hauteur minimale pour éviter l'écrasement
            }
            .frame(width: 300)
        }
        .padding(.top, 20)
        .padding(.horizontal, 30)
        .padding(.bottom, 30)
    }
}

#Preview {
    OrganizerView()
}
