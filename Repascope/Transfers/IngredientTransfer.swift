//
//  IngredientTransfer.swift
//  Repascope
//
//  Created by Mickael Thibouret on 05/05/2026.
//

import Foundation
import SwiftUI
import SwiftData
import UniformTypeIdentifiers


struct IngredientTransfer: Transferable, Codable {
    let persistentID: PersistentIdentifier
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .ingredientTransfer)
    }
}

extension UTType {
    static let ingredientTransfer = UTType(exportedAs: "com.repascope.ingredientTransfer")
}
