//
//  GuestIconView.swift
//  Repascope
//
//  Created by Mickael Thibouret on 29/05/2026.
//

import SwiftUI

struct GuestIconView: View {
    
    let guest: Guest
    
    var guestColor: Color {
        Color.init(hex: guest.colorHex)
    }
    
    var body: some View {
        Circle()
            .fill(guestColor.opacity(0.3))
            .strokeBorder(guestColor)
            .overlay {
                let firstLetter = String(guest.name.first ?? Character("?"))
                Text(firstLetter)
                    .foregroundStyle(guestColor)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
            }
    }
}

#Preview {
    GuestIconView(guest: Guest(name: "Mickael", colorHex: "4076f5"))
        .frame(width: 50, height: 50)
}
