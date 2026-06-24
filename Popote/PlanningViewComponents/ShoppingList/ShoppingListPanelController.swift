//
//  ShoppingListPanelController.swift
//  Popote
//

import SwiftUI
import AppKit
import SwiftData
import Combine

final class ShoppingListPanelController: ObservableObject {

    private var panel: NSPanel?
    private let modelContainer: ModelContainer
    private let appSettings: AppSettings

    init(
        modelContainer: ModelContainer,
        appSettings: AppSettings
    ) {
        self.modelContainer = modelContainer
        self.appSettings = appSettings
    }

    @MainActor
    func show(weekToDisplay: Date) {
        if let panel {
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let contentView = ShoppingListPanelView(
            date: weekToDisplay,
            closePanelAction: { [weak self] in
                self?.close()
            }
        )
        .modelContainer(modelContainer)
        .environment(appSettings)
        .frame(minWidth: 360, minHeight: 500)

        let hostingController = NSHostingController(rootView: contentView)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 600),
            styleMask: [
                .titled,
                .closable,
                .resizable,
                .utilityWindow
            ],
            backing: .buffered,
            defer: false
        )

        panel.title = "Liste de courses"
        panel.contentViewController = hostingController
        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]
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
