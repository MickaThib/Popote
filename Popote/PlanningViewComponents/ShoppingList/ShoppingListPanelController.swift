//
//  ShoppingListPanelController.swift
//  Popote
//
//  Created by THIBOURET  Mickael on 12/06/2026.
//

import SwiftUI
import SwiftData
import AppKit
import Combine

final class ShoppingListPanelController: ObservableObject {
    
    private var panel: NSPanel?
    private let modelContainer: ModelContainer
        
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    @MainActor
    func show(weekToDisplay: Date) {
        if let panel {
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let contentView = ShoppingListPanelView(date: weekToDisplay, closePanelAction: { [weak self] in
            self?.close()
        })
            .modelContainer(modelContainer)
            .frame(minWidth: 360, minHeight: 500)
        
        let hostingController = NSHostingController(rootView: contentView)
        
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 600),
            styleMask: [.titled, .closable, .resizable, .utilityWindow, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        panel.title = "Liste de courses"
        panel.contentViewController = hostingController
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        
        self.panel = panel
        
    }
    
    @MainActor
    func close() {
        panel?.close()
        panel = nil
    }
}
