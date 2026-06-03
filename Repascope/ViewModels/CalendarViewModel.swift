//
//  CalendarViewModel.swift
//  Planingo
//
//  Created by Mickael on 20/02/2026.
//

import Foundation
import Combine

class CalendarViewModel: ObservableObject {
    
    @Published var weeks: [Week] = []
    
    static let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "fr_FR")
        cal.firstWeekday = 2
        return cal
    }()
    
    func generateWeek(from date:Date, firstDay: Weekday) -> Week? {
                
        guard let startFriday = CalendarViewModel.firstDayOfWeek(startWeekday: firstDay, from: date) else { return nil }
        
        let days = (0..<8).compactMap {
            CalendarViewModel.calendar.date(byAdding: .day, value: $0, to: startFriday)
        }
        
        return Week(id: startFriday, days: days)
    }
    
    // Helper : calcule le vendredi précédent (ou le jour même si c'est vendredi) en utilisant le composant .weekday
    static func firstDayOfWeek(startWeekday: Weekday, from date: Date) -> Date? {
        let startOfDay = calendar.startOfDay(for: date)
        // weekday: 1 = dimanche, 6 = vendredi (dans le calendrier grégorien)
        let weekday = calendar.component(.weekday, from: startOfDay)
        let daysToSubtract = (weekday - startWeekday.rawValue + 7) % 7 // 6 = vendredi
        return calendar.date(byAdding: .day, value: -daysToSubtract, to: startOfDay)
    }
    
    static func shoppingWeekStart(for date: Date) -> Date? {
        let calendar = CalendarViewModel.calendar
        let startOfDay = calendar.startOfDay(for: date)

        return firstDayOfWeek(
            startWeekday: .saturday,
            from: startOfDay
        )
    }
    
    static func shoppingListDate(for planningDate: Date) -> Date {
        guard let planningWeekStart = firstDayOfWeek(
            startWeekday: .friday,
            from: planningDate
        ) else {
            return planningDate
        }

        return calendar.date(
            byAdding: .day,
            value: 1,
            to: planningWeekStart
        ) ?? planningDate
    }
    
    static func isWeekend(_ date: Date) -> Bool {
        Calendar.current.isDateInWeekend(date)
    }
}

enum Weekday: Int {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
}

struct Week: Identifiable, Hashable {
    let id: Date // Le premier jour de la semaine
    let days: [Date]
}


