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
                let demain = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                
                let quiche = MealItem(title: "Quiche", photo: nil)
                let haricots = MealItem(title: "Haricots verts", photo: nil)
                let poisson = MealItem(title: "Poisson pané", photo: nil)
                let riz = MealItem(title: "Riz", photo: nil)
                let poulet =  MealItem(title: "Escalope de poulet", photo: nil)
                
                // Insérer les MealItems d'abord
                modelContext.insert(quiche)
                modelContext.insert(haricots)
                modelContext.insert(poisson)
                modelContext.insert(riz)
                modelContext.insert(poulet)
                
                // Puis les PlannedMeals
                let pm1 = PlannedMeal(date: Date(), slot: .noon, position: 0, meal: poisson)
                let pm2 = PlannedMeal(date: Date(), slot: .noon, position: 1, meal: riz)
                let pm3 = PlannedMeal(date: Date(), slot: .evening, position: 0, meal: quiche)
                let pm4 = PlannedMeal(date: demain, slot: .evening, position: 0, meal: poulet)
                let pm5 = PlannedMeal(date: demain, slot: .evening, position: 1, meal: haricots)
                
                
                modelContext.insert(pm1)
                modelContext.insert(pm2)
                modelContext.insert(pm3)
                modelContext.insert(pm4)
                modelContext.insert(pm5)
                
                testMealItems = [quiche, haricots, poisson, riz, poulet]
                testPlannedMeals = [pm1, pm2, pm3, pm4, pm5]
                
                try? modelContext.save()
            }
            Button("Delete test data") {
                testPlannedMeals.forEach { modelContext.delete($0) }
                testMealItems.forEach { modelContext.delete($0) }
                testPlannedMeals = []
                testMealItems = []
            }
            
            Button("Delete all") {
                try? modelContext.delete(model: PlannedMeal.self)
                try? modelContext.delete(model: MealItem.self)
            }
        }
    }
}

#Preview {
    OrganizerView()
}
