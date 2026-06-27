//
//  KeyEventView.swift
//  Popote
//
//  Created by Mickael on 27/06/2026.
//

import AppKit
import SwiftUI

struct KeyEventView: NSViewRepresentable {
    let onKeyDown: (NSEvent) -> Bool
    
    func makeNSView(context: Context) -> NSView {
        let view = KeyCatcherView()
        view.onKeyDown = onKeyDown
        
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let view = nsView as? KeyCatcherView {
            view.onKeyDown = onKeyDown
            
            DispatchQueue.main.async {
                view.window?.makeFirstResponder(view)
            }
        }
    }
}

final class KeyCatcherView: NSView {
    var onKeyDown: ((NSEvent) -> Bool)?
    
    override var acceptsFirstResponder: Bool {
        true
    }
    
    override func keyDown(with event: NSEvent) {
        if onKeyDown?(event) == true {
            return
        }
        
        super.keyDown(with: event)
    }
}
