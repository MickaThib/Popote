//
//  GuestGroupView.swift
//  Repascope
//
//  Created by Mickael on 31/05/2026.
//

import SwiftUI

struct GuestGroupView: View {
    
    let guestsGroup: GuestsGroup
    let deleteAction: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        VStack {
            Text(guestsGroup.title)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .background(Color.white)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.theme)
        }
        .overlay (alignment: .topTrailing) {
            if isHovering {
                Button {
                    deleteAction()
                } label: {
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(Color.theme)
                        .font(.system(size: 20, weight: .light))
                        .padding()
                }
                .buttonStyle(.plain)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onHover { hover in
            isHovering = hover
        }
    }
}

#Preview {
    GuestGroupView(guestsGroup: GuestsGroup(title: "Mini tribu"), deleteAction: {})
}
