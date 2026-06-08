//
//  GuestIconView.swift
//  Popote
//
//  Created by Mickael Thibouret on 29/05/2026.
//

import SwiftUI

struct GuestIconView: View {
    
    let guest: Guest
    
    var guestColor: Color {
        Color(displayP3Hex: guest.colorHex)
    }
    
    var body: some View {
        GeometryReader { geo in
            Circle()
                .fill(guestColor.opacity(0.3))
                .strokeBorder(guestColor)
                .overlay {
                    let firstLetter = String(guest.name.first ?? Character("?"))
                    Text(firstLetter)
                        .foregroundStyle(guestColor)
                        .font(.system(size: geo.size.width * 0.5, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.5)
                }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    GuestIconView(guest: Guest(name: "Mickael", colorHex: "4076f5"))
        .frame(width: 50, height: 50)
}
