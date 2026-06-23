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
    
    @State private var weekToDisplay: Date = Date()
    @State private var showSettings: Bool = false
    @State private var refreshID = UUID()
    
    private let calendarViewModel = CalendarViewModel()
    
    var title: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "d MMMM yyyy"
        return "Planning de la semaine du \(formatter.string(from: weekToDisplay))"
    }
    
    var body: some View {
        HStack(spacing: 30) {
            
            // MARK: - Contenu principal
            VStack(spacing: 0) {
                planningNavigationHeader
                
                PlanningView(weekToDisplay: weekToDisplay)
                    .frame(minWidth: 700, maxWidth: .infinity)
                    .id(refreshID)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: appSettings.mainColor.opacity(0.3), radius: 6, x: 5, y: 5)
            
            // MARK: - Volet droit
            VSplitView {
                MealList()
                    .frame(minHeight: 100)
                
                ShoppingListView(
                    date: calendarViewModel.displayedShoppingListStart(forPlanningDate: weekToDisplay)
                )
                .padding(.top)
                .frame(minHeight: 100)
            }
            .frame(width: 300)
            .shadow(color: appSettings.mainColor.opacity(0.3), radius: 6, x: 5, y: 5)
        }
        .padding(.top, 20)
        .padding(.horizontal, 30)
        .padding(.bottom, 30)
        .toolbar {
            
            // MARK: DEBUG
            ToolbarItem {
                Button("Réinitialiser l’accueil") {
                    UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
                }
            }
            // END DEBUG
            
            
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
            
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    weekToDisplay = Date()
                } label: {
                    Label("Aujourd'hui", systemImage: "calendar")
                        .labelStyle(.titleAndIcon)
                }
            }
            
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
            SettingsView {
                refreshID = UUID()
            }
        }
    }
    
    private var planningNavigationHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Button {
                moveDisplayedWeek(by: -7)
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
                moveDisplayedWeek(by: 7)
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
        .background(appSettings.mainColor)
    }
    
    private func moveDisplayedWeek(by numberOfDays: Int) {
        if let newWeekToDisplay = CalendarViewModel.calendar.date(
            byAdding: .day,
            value: numberOfDays,
            to: weekToDisplay
        ) {
            weekToDisplay = newWeekToDisplay
        }
    }
    
    func createWeekTitleString() -> String {
        guard let startOfWeek = CalendarViewModel.firstDayOfWeek(
            startWeekday: calendarViewModel.preferredFirstDay,
            from: weekToDisplay
        ),
        let finalDate = CalendarViewModel.calendar.date(
            byAdding: .day,
            value: calendarViewModel.numberOfDaysInPlanning - 1,
            to: startOfWeek
        ) else {
            return "Planning de la semaine"
        }
        
        let startDateStr = startOfWeek.formatted(.dateTime.day().month(.wide))
        let finalDateStr = finalDate.formatted(.dateTime.day().month(.wide).year())
        return "Semaine du " + startDateStr + " au " + finalDateStr
    }
}

#Preview {
    OrganizerView()
        .environment(AppSettings())
}
