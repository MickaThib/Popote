//
//  ColorExtension.swift
//  Repascope
//
//  Created by Mickael Thibouret on 29/05/2026.
//

import Foundation
import SwiftUI
import AppKit

extension Color {
    
    init(hex: String) {
        let hex = hex
            .trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let r, g, b, a: UInt64
        
        switch hex.count {
        case 6:
            r = (int >> 16) & 0xFF
            g = (int >> 8) & 0xFF
            b = int & 0xFF
            a = 255
            
        case 8:
            r = (int >> 24) & 0xFF
            g = (int >> 16) & 0xFF
            b = (int >> 8) & 0xFF
            a = int & 0xFF
            
        default:
            r = 0
            g = 0
            b = 0
            a = 255
        }
        
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Color {
    
    var hexString: String {
        let nsColor = NSColor(self)
            .usingColorSpace(.displayP3) ?? .black
        
        let red = Int(nsColor.redComponent * 255)
        let green = Int(nsColor.greenComponent * 255)
        let blue = Int(nsColor.blueComponent * 255)
        let alpha = Int(nsColor.alphaComponent * 255)
        
        return String(format: "%02X%02X%02X%02X", red, green, blue, alpha)
    }
}
