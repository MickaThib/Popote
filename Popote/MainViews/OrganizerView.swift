//
//  PlanningView.swift
//  Popote
//
//  Created by Mickael on 29/04/2026.
//

import SwiftUI
import SwiftData

struct OrganizerView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    
    @AppStorage("PlanningFirstDay") private var planningFirstDayRawValue: Int = Weekday.friday.rawValue
        
    @State var weekToDisplay: Date = Date()
    
    private let calendarViewModel = CalendarViewModel()
    
    var title: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "d MMMM yyyy"
        return "Planning de la semaine du \(formatter.string(from: weekToDisplay))"
    }
    
    @State var showSettings: Bool = false
        
    var body: some View {
        
        HStack(spacing: 30) {
            
            //MARK: Contenu principal
            VStack (spacing: 0) {
                //MARK: Navigation buttons
                HStack(alignment: .firstTextBaseline) {
                    Button {
                        if let newWeekToDisplay = CalendarViewModel.calendar.date(byAdding: .day, value: -7, to: weekToDisplay) {
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
                    
                    Text(createWeekTitleString())
                        .font(.system(size: 18, weight: .bold))
                    
                    Spacer()
                    
                    Button {
                        if let newWeekToDisplay = CalendarViewModel.calendar.date(byAdding: .day, value: 7, to: weekToDisplay) {
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
                .foregroundStyle(Color.white)
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 12)
                .background(
                    appSettings.mainColor
                )
                
                PlanningView(weekToDisplay: weekToDisplay)
                    .frame(minWidth: 700, maxWidth: .infinity)
            }
            .background(
                Color.white
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 10)
            )
            .shadow(color: appSettings.mainColor.opacity(0.3),radius: 6, x: 5, y: 5)
            
            //MARK: Volet droit
            VSplitView {
                
                //Section haute
                MealList()
                .frame(minHeight: 100) // hauteur minimale pour éviter l'écrasement

                                
                //Section basse
                ShoppingListView(
                    date: calendarViewModel.shoppingListDate(for: weekToDisplay)
                )
                .frame(minHeight: 100) // hauteur minimale pour éviter l'écrasement
            }
            .frame(width: 300)
            .shadow(color: appSettings.mainColor.opacity(0.3),radius: 6, x: 5, y: 5)

        }
        .padding(.top, 20)
        .padding(.horizontal, 30)
        .padding(.bottom, 30)
        .toolbar {
            
            //MARK: Impression du planning en cours
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    let exportView = PlanningPrintView(weekToDisplay: weekToDisplay)
                        .environment(\.modelContext, modelContext)
                    PDFExporter.print(view: exportView, appStettings: appSettings, title: title)
                } label: {
                    Label("Imprimer le planning", systemImage: "printer")
                        .labelStyle(.iconOnly)
                }
            }
            
            ToolbarSpacer(.fixed)
            
            //MARK: Retour à la date du jour
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    weekToDisplay = Date()
                } label: {
                    Label("Aujourd'hui", systemImage: "calendar")
                        .labelStyle(.titleAndIcon)
                }
            }
            
            //MARK: Réglages
            ToolbarItemGroup(placement: .navigation) {
                Button {
                    showSettings = true
                } label: {
                    Label("Réglages", systemImage: "gear")
                        .labelStyle(.iconOnly)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
           SettingsView()
        }
    }
    
    func createWeekTitleString() -> String {
        
        let startWeekday = Weekday(rawValue: planningFirstDayRawValue) ?? .friday
        
        guard let startOfWeek = CalendarViewModel.firstDayOfWeek(startWeekday: startWeekday, from: weekToDisplay),
              let finalDate = CalendarViewModel.calendar.date(byAdding: .day, value: 7, to: startOfWeek)
        else {
            return "Planning de la semaine"
        }
                        
        let startDateStr = startOfWeek.formatted(.dateTime.day().month(.wide))
        let finalDateStr = finalDate.formatted(.dateTime.day().month(.wide).year())
        return "Semaine du " + startDateStr + " au " + finalDateStr
    }
}

#Preview {
    OrganizerView()
}
