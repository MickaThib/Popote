//
//  GuestsGroup.swift
//  Repascope
//
//  Created by Mickael Thibouret on 29/05/2026.
//

import Foundation
import SwiftData

@Model
final class GuestsGroup {
    var title: String
    
    @Relationship(inverse: \Guest.groups)
    var guests: [Guest]
    
    init(title: String, guests: [Guest] = []) {
        self.title = title
        self.guests = guests
    }
}
