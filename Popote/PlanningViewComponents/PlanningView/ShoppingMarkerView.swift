//
//  ShoppingMarkerView.swift
//  Popote
//
//  Created by THIBOURET  Mickael on 19/06/2026.
//

import SwiftUI

struct ShoppingMarkerView: View {
    
    @Environment(AppSettings.self) private var appSettings
    
    let moment: ShoppingMoment
    
    var body: some View {
        VStack {
            Image(systemName: "cart.fill")
                .frame(maxHeight: .infinity)
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 4)
        .background(
            Capsule()
                .fill(.secondary.opacity(0.12))
        )
        .frame(maxHeight: .infinity, alignment: .center)
        .help(label)
    }
    
    private var label: String {
        switch moment {
        case .morning:
            return "Courses prévues — nouvelle liste dès midi"
        case .afternoon:
            return "Courses prévues — nouvelle liste dès ce soir"
        case .evening:
            return "Courses prévues — nouvelle liste dès demain midi"
        }
    }
}
#Preview {
    ShoppingMarkerView(moment: .morning)
        .frame(height: 150)
        .environment(AppSettings())
}
