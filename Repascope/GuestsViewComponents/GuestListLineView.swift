//
//  GuestListLineView.swift
//  Repascope
//
//  Created by Mickael Thibouret on 29/05/2026.
//

import SwiftUI

struct GuestListLineView: View {
    
    let guest: Guest
    let editAction: () -> Void
    
    var body: some View {
        HStack {
            GuestIconView(guest: guest)
                .frame(width: 50, height: 50)
            
            Text(guest.name)
                .font(.system(size: 18))
            
            Spacer()
            
            Button {
                editAction()
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 20))
            }
            .buttonStyle(.plain)
            .padding()
        }
    }
}

#Preview {
    GuestListLineView(guest: Guest(name: "Mickael", colorHex: "4076f5"), editAction: {})
        .frame(width: 400, height: 60)
}
