//
//  MealTransfer.swift
//  Repascope
//
//  Created by Mickael Thibouret on 15/05/2026.
//

import Foundation
import SwiftUI
import SwiftData
import UniformTypeIdentifiers


struct MealTransfer: Transferable, Codable {
    let persistentID: PersistentIdentifier
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .mealTransfer)
    }
}

extension UTType {
    static let mealTransfer = UTType(exportedAs: "com.repascope.mealTransfer")
}
