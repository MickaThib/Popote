//
//  PlanningDropTransfer.swift
//  Popote
//
//  Created by Mickael on 17/05/2026.
//

import Foundation
import SwiftData
import UniformTypeIdentifiers
import CoreTransferable

enum PlanningDropKind: String, Codable {
    case mealItem
    case plannedMeal
}

struct PlanningDropTransfer: Transferable, Codable {
    
    let persistentID: PersistentIdentifier
    let kind: PlanningDropKind
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .planningDropTransfer)
    }
}

extension UTType {
    static let planningDropTransfer = UTType(
        exportedAs: "com.popote.planning-drop-transfer"
    )
}
