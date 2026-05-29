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
    let deleteAction: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack {
            GuestIconView(guest: guest)
                .frame(width: 40, height: 40)
                .padding(.leading)
            
            Text(guest.name)
                .font(.system(size: 18))
                .foregroundStyle(Color.themeContrast)
            
            Spacer()
            
            if isHovering {
                Button {
                    editAction()
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.themeContrast.opacity(0.5))
                }
                .buttonStyle(.plain)
                .padding(.trailing, 8)
                
                Button {
                    deleteAction()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.themeContrast.opacity(0.5))
                }
                .buttonStyle(.plain)
                .padding(.trailing)
            }
        }
        .onHover { hover in
            isHovering = hover
        }
    }
}

#Preview {
    GuestListLineView(guest: Guest(name: "Mickael", colorHex: "4076f5"), editAction: {}, deleteAction: {})
        .frame(width: 400, height: 60)
}
