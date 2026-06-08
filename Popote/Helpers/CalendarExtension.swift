//
//  Helpers.swift
//  Popote
//
//  Created by Mickael on 12/05/2026.
//

import Foundation

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
}
