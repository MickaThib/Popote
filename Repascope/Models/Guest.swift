//
//  Item.swift
//  Repascope
//
//  Created by Mickael on 29/04/2026.
//

import Foundation
import SwiftData

@Model
final class Guest {
    var name: String
    var colorHex: String
    
    var groups: [GuestsGroup] = []
    
    init(name: String, colorHex: String = "6762A4") {
        self.name = name
        self.colorHex = colorHex
    }
}
