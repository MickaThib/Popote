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
            HStack {
                Text(guestsGroup.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.theme)
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .background(
                Rectangle()
                    .fill(Color.theme.opacity(0.1))
                    .stroke(Color.theme)
            )
            .overlay(alignment: .trailing) {
                if isHovering {
                    HStack(spacing: 6) {
                        Button {
                            //TODO: Edit action
                        } label: {
                            Image(systemName: "pencil.circle")
                                .foregroundStyle(Color.theme)
                                .font(.system(size: 16, weight: .light))
                        }
                        
                        Button {
                            deleteAction()
                        } label: {
                            Image(systemName: "xmark.circle")
                                .foregroundStyle(Color.theme)
                                .font(.system(size: 16, weight: .light))
                                .padding(.trailing)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .onHover { hover in
                isHovering = hover
            }
            
            VStack {
                ForEach(guestsGroup.guests) { guest in
                    GuestListLineView(guest: guest, deleteAction: {}, isEditing: false, startEditing: {}, stopEditing: {})
                        .padding(.horizontal)
                }
        
                Spacer()
            }
            .frame(maxHeight: .infinity)
            .padding(.top)
            //TODO: Drop destination
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .background(Color.white)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.theme)
        }
        
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    let guestsGroup = GuestsGroup(title: "Mini tribu", guests: [
        Guest(name: "Mickael", colorHex: "3b56cc"),
        Guest(name: "Erwann", colorHex: "121256"),
        Guest(name: "Eliott", colorHex: "ccaa00"),
        Guest(name: "Soline", colorHex: "ff0055")
    ])
    GuestGroupView(guestsGroup: guestsGroup, deleteAction: {})
        .frame(width: 270)
}
