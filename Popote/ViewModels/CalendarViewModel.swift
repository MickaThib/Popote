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
    @AppStorage("NumberOfDaysInPlanning") private var numberOfDaysInPlanningRawValue: Int = DaysInPlanning.eightDays.rawValue
    @AppStorage("ShoppingDay") private var shoppingDayRawValue: Int = Weekday.saturday.rawValue
    @AppStorage("ShoppingDayMoment") private var shoppingDayMomentRawValue: Int = ShoppingMoment.morning.rawValue
    
    var preferredFirstDay: Weekday {
        Weekday(rawValue: planningFirstDayRawValue) ?? .friday
    }
    
    var numberOfDaysInPlanning: Int {
        DaysInPlanning(rawValue: numberOfDaysInPlanningRawValue)?.rawValue ?? DaysInPlanning.eightDays.rawValue
    }
    
    var shoppingDay: Weekday {
        Weekday(rawValue: shoppingDayRawValue) ?? .saturday
    }
    
    var shoppingMoment: ShoppingMoment {
        ShoppingMoment(rawValue: shoppingDayMomentRawValue) ?? .morning
    }
    
    static let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "fr_FR")
        cal.firstWeekday = 2
        return cal
    }()
    
    /// Génère les jours du planning à afficher, en fonction :
    /// - du jour choisi comme premier jour du planning ;
    /// - du nombre de jours choisi dans les réglages.
    func generateWeek(from date: Date) -> Week? {
        guard let startDay = CalendarViewModel.firstDayOfWeek(
            startWeekday: preferredFirstDay,
            from: date
        ) else {
            return nil
        }
        
        let days = (0..<numberOfDaysInPlanning).compactMap {
            CalendarViewModel.calendar.date(byAdding: .day, value: $0, to: startDay)
        }
        
        return Week(id: startDay, days: days)
    }
    
    /// Calcule le premier jour de la période contenant `date`.
    /// Exemple : si `startWeekday == .friday`, on obtient le vendredi précédent,
    /// ou le jour même si `date` est déjà un vendredi.
    static func firstDayOfWeek(startWeekday: Weekday, from date: Date) -> Date? {
        let startOfDay = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: startOfDay)
        let daysToSubtract = (weekday - startWeekday.rawValue + 7) % 7
        return calendar.date(byAdding: .day, value: -daysToSubtract, to: startOfDay)
    }
    
    /// Première liste de courses pertinente pour le planning affiché.
    ///
    /// Si le planning commence le vendredi et que les courses sont le samedi,
    /// cette fonction renvoie le samedi de cette période.
    func displayedShoppingListStart(forPlanningDate date: Date) -> Date {
        guard let planningStart = CalendarViewModel.firstDayOfWeek(
            startWeekday: preferredFirstDay,
            from: date
        ) else {
            return CalendarViewModel.calendar.startOfDay(for: date)
        }
        
        var shoppingStart = CalendarViewModel.firstDayOfWeek(
            startWeekday: shoppingDay,
            from: planningStart
        ) ?? planningStart
        
        if shoppingStart < planningStart {
            shoppingStart = CalendarViewModel.calendar.date(
                byAdding: .day,
                value: 7,
                to: shoppingStart
            ) ?? shoppingStart
        }
        
        return CalendarViewModel.calendar.startOfDay(for: shoppingStart)
    }
    
    /// Détermine dans quelle liste de courses doit tomber un repas précis.
    ///
    /// Hypothèse métier :
    /// - courses le matin : la nouvelle liste commence au repas du midi ;
    /// - courses l'après-midi : la nouvelle liste commence au repas du soir.
    ///
    /// La date renvoyée sert d'identifiant de liste via `ShoppingList.weekStart`.
    func shoppingListStart(forMealDate mealDate: Date, slot: MealSlot) -> Date? {

        guard let shoppingDate = shoppingDateBeforeOrOnMealDate(
            mealDate,
            slot: slot
        ) else {
            return nil
        }

        return CalendarViewModel.calendar.startOfDay(for: shoppingDate)
    }
    
    private func shoppingDateBeforeOrOnMealDate(_ mealDate: Date, slot: MealSlot) -> Date? {
        let startOfMealDate = CalendarViewModel.calendar.startOfDay(for: mealDate)

        guard var shoppingDate = CalendarViewModel.firstDayOfWeek(
            startWeekday: shoppingDay,
            from: startOfMealDate
        ) else {
            return nil
        }

        if shoppingDate > startOfMealDate {
            shoppingDate = CalendarViewModel.calendar.date(
                byAdding: .day,
                value: -7,
                to: shoppingDate
            ) ?? shoppingDate
        }

        if isSameDay(mealDate, shoppingDate) {
            switch shoppingMoment {
            case .morning:
                // Les courses du matin couvrent midi et soir du même jour.
                return shoppingDate

            case .afternoon:
                // Le midi du jour des courses appartient encore à la liste précédente.
                if slot == .noon {
                    return CalendarViewModel.calendar.date(
                        byAdding: .day,
                        value: -7,
                        to: shoppingDate
                    )
                } else {
                    return shoppingDate
                }

            case .evening:
                // Midi et soir du jour des courses appartiennent encore à la liste précédente.
                return CalendarViewModel.calendar.date(
                    byAdding: .day,
                    value: -7,
                    to: shoppingDate
                )
            }
        }

        return shoppingDate
    }
    
    private func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        CalendarViewModel.calendar.isDate(lhs, inSameDayAs: rhs)
    }
    
    static func isWeekend(_ date: Date) -> Bool {
        Calendar.current.isDateInWeekend(date)
    }
    
    func isShoppingDay(_ date: Date) -> Bool {
        let weekday = CalendarViewModel.calendar.component(.weekday, from: date)
        return weekday == shoppingDay.rawValue
    }

    func shouldShowShoppingMarker(before slot: MealSlot, on date: Date) -> Bool {
        guard isShoppingDay(date) else { return false }

        switch shoppingMoment {
        case .morning:
            return slot == .noon
        case .afternoon:
            return slot == .evening
        case .evening:
            return false
        }
    }

    func shouldShowShoppingMarkerAfterEvening(on date: Date) -> Bool {
        isShoppingDay(date) && shoppingMoment == .evening
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
}

struct Week: Identifiable, Hashable {
    let id: Date
    let days: [Date]
}
