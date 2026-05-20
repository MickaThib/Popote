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
        
    var body: some View {
        
        HStack(spacing: 20) {
            
            //MARK: Contenu principal
            VStack (spacing: 0) {
                //MARK: Navigation buttons
                HStack(alignment: .firstTextBaseline) {
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
                    .foregroundStyle(Color.theme)
                    
                    Spacer()
                    
                    Text(createWeekTitleString())
                        .font(.title2)
                    
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
                    .foregroundStyle(Color.theme)

                }
                .padding([.horizontal, .top])
                .padding(.bottom, 0)
                
                PlanningView(weekToDisplay: weekToDisplay)
                    .frame(maxWidth: .infinity)
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
            )
            
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
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    //TODO: Imprimer le planning
                } label: {
                    Label("Imprimer le planning", systemImage: "printer")
                        .labelStyle(.iconOnly)
                }
                Button {
                    weekToDisplay = Date()
                } label: {
                    Label("Aujourd'hui", systemImage: "calendar")
                        .labelStyle(.titleAndIcon)
                }
            }
            ToolbarItemGroup(placement: .navigation) {
                Button {
                    //TODO: Settings
                } label: {
                    Label("Réglages", systemImage: "gear")
                        .labelStyle(.iconOnly)
                }
            }
        }
    }
    
    func createWeekTitleString() -> String {
        
        guard let startOfWeek = calendarViewModel.firstDayOfWeek(startWeekday: .friday, from: weekToDisplay),
              let finalDate = calendarViewModel.calendar.date(byAdding: .day, value: 7, to: startOfWeek)
        else {
            return "Planning de la semaine"
        }
                        
        let startDateStr = startOfWeek.formatted(.dateTime.day().month())
        let finalDateStr = finalDate.formatted(.dateTime.day().month().year())
        return "Semaine du " + startDateStr + " au " + finalDateStr
    }
}

#Preview {
    OrganizerView()
}
