//
//  IngredientTransfer.swift
//  Popote
//
//  Created by Mickael Thibouret on 05/05/2026.
//

import Foundation
import SwiftUI
import SwiftData
import UniformTypeIdentifiers


struct GuestTransfer: Transferable, Codable {
    let persistentID: PersistentIdentifier
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .guestTransfer)
    }
}

extension UTType {
    static let guestTransfer = UTType(exportedAs: "com.popote.guestTransfer")
}
