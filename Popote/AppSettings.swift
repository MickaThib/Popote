//
//  AppSettings.swift
//  Popote
//
//  Created by THIBOURET  Mickael on 18/06/2026.
//

import SwiftUI
import Observation

@Observable
final class AppSettings {
    
    var mainColorHex: String {
        didSet {
            UserDefaults.standard.set(mainColorHex, forKey: "mainColorHex")
        }
    }
    
    var secondaryColorHex: String {
        didSet {
            UserDefaults.standard.set(secondaryColorHex, forKey: "secondaryColorHex")
        }
    }
    
    init() {
        self.mainColorHex = UserDefaults.standard.string(forKey: "mainColorHex") ?? "#6762A4"
        self.secondaryColorHex = UserDefaults.standard.string(forKey: "secondaryColorHex") ?? "#FA8070"
    }
    
    var mainColor: Color {
        Color(displayP3Hex: mainColorHex)
    }
    
    var secondaryColor: Color {
        Color(displayP3Hex: secondaryColorHex)
    }
    
    // Calcule automatiquement la couleur principale contrastée
    var mainColorContrast: Color {
        return mainColor.exposureAdjust(-0.5)
    }
    
}
