//
//  ShoppingReminderExporter.swift
//  Popote
//
//  Created by THIBOURET  Mickael on 07/06/2026.
//

import Foundation
import EventKit

final class ShoppingReminderExporter {
    
    private let eventStore = EKEventStore()
    
    func export(
        listTitle: String,
        items: [ShoppingReminderExportItem]
    ) async throws {
        
        let granted = try await requestReminderAccess()
        
        guard granted else {
            throw ShoppingReminderExportError.accessDenied
        }
        
        let calendar = try makeReminderList(named: listTitle)
        
        for item in items {
            let reminder = EKReminder(eventStore: eventStore)
            reminder.title = item.name
            reminder.calendar = calendar
            reminder.isCompleted = item.isCompleted
            
            try eventStore.save(reminder, commit: false)
        }
        
        try eventStore.commit()
    }
    
    private func requestReminderAccess() async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            eventStore.requestFullAccessToReminders { granted, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    private func makeReminderList(named title: String) throws -> EKCalendar {
        let calendar = EKCalendar(for: .reminder, eventStore: eventStore)
        calendar.title = title
        
        if let source = eventStore.defaultCalendarForNewReminders()?.source {
            calendar.source = source
        } else if let source = eventStore.sources.first(where: { $0.sourceType == .calDAV }) {
            calendar.source = source
        } else if let source = eventStore.sources.first {
            calendar.source = source
        } else {
            throw ShoppingReminderExportError.noReminderSource
        }
        
        try eventStore.saveCalendar(calendar, commit: true)
        return calendar
    }
}

enum ShoppingReminderExportError: LocalizedError {
    case accessDenied
    case noReminderSource
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "L’accès aux rappels a été refusé."
        case .noReminderSource:
            return "Aucune source de rappels n’est disponible."
        }
    }
}
