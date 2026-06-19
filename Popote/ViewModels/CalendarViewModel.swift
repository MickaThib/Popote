//
//  CalendarViewModel.swift
//  Planingo
//
//  Created by Mickael on 20/02/2026.
//

import Foundation
import Combine
import SwiftUI

class CalendarViewModel: ObservableObject {
    
    @Published var weeks: [Week] = []
    
    @AppStorage("PlanningFirstDay") private var planningFirstDayRawValue: Int = Weekday.friday.rawValue
    @AppStorage("NumberOfDaysInPlanning") private var numberOfDaysInPlanningRawValue: Int = 8
    
    var preferredFirstDay: Weekday {
        Weekday(rawValue: planningFirstDayRawValue) ?? .friday
    }
    
    static let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "fr_FR")
        cal.firstWeekday = 2
        return cal
    }()
    
    func generateWeek(from date:Date, firstDay: Weekday) -> Week? {
                
        guard let startDay = CalendarViewModel.firstDayOfWeek(startWeekday: firstDay, from: date) else { return nil }
        
        let days = (0..<numberOfDaysInPlanningRawValue).compactMap {
            CalendarViewModel.calendar.date(byAdding: .day, value: $0, to: startDay)
        }
        
        return Week(id: startDay, days: days)
    }
    
    // Helper : calcule le jour de référence précédent (ou le jour même si c'est le même jour) en utilisant le composant .weekday
    static func firstDayOfWeek(startWeekday: Weekday, from date: Date) -> Date? {
        let startOfDay = calendar.startOfDay(for: date)
        // weekday: 1 = dimanche, 6 = vendredi (dans le calendrier grégorien)
        let weekday = calendar.component(.weekday, from: startOfDay)
        let daysToSubtract = (weekday - startWeekday.rawValue + 7) % 7 // 6 = vendredi
        return calendar.date(byAdding: .day, value: -daysToSubtract, to: startOfDay)
    }
    
    func shoppingWeekStart(for date: Date) -> Date? {
        
        let calendar = CalendarViewModel.calendar
        let startOfDay = calendar.startOfDay(for: date)

        return CalendarViewModel.firstDayOfWeek(
            startWeekday: preferredFirstDay.next,
            from: startOfDay
        )
    }
    
    func shoppingListDate(for planningDate: Date) -> Date {
        guard let planningWeekStart = CalendarViewModel.firstDayOfWeek(
            startWeekday: preferredFirstDay,
            from: planningDate
        ) else {
            return planningDate
        }

        return CalendarViewModel.calendar.date(
            byAdding: .day,
            value: 1,
            to: planningWeekStart
        ) ?? planningDate
    }
    
    static func isWeekend(_ date: Date) -> Bool {
        Calendar.current.isDateInWeekend(date)
    }
}

enum Weekday: Int, CaseIterable, Identifiable {
    var id: Int {
        self.rawValue
    }
    
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    
    var string: String {
        switch self {
        case .monday: return "Lundi"
        case .tuesday: return "Mardi"
        case .wednesday: return "Mercredi"
        case .thursday: return "Jeudi"
        case .friday: return "Vendredi"
        case .saturday: return "Samedi"
        case .sunday: return "Dimanche"
        }
    }
    
    var next: Weekday {
        switch self {
        case .monday: return .tuesday
        case .tuesday: return .wednesday
        case .wednesday: return .thursday
        case .thursday: return .friday
        case .friday: return .saturday
        case .saturday: return .sunday
        case .sunday: return .monday
        }
    }
}

struct Week: Identifiable, Hashable {
    let id: Date // Le premier jour de la semaine
    let days: [Date]
}


