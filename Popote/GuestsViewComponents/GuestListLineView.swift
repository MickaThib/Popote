//
//  GuestListLineView.swift
//  Popote
//
//  Created by Mickael Thibouret on 29/05/2026.
//

import SwiftUI

struct GuestListLineView: View {
    
    @Bindable var guest: Guest
    
    let deleteAction: () -> Void
    let isEditing: Bool
    let startEditing: () -> Void
    let stopEditing: () -> Void
    
    @State private var isHovering = false
    @FocusState private var nameFieldFocused: Bool
    
    private var colorBinding: Binding<Color> {
        Binding(
            get: {
                Color(displayP3Hex: guest.colorHex)
            },
            set: { newColor in
                guest.colorHex = newColor.displayP3HexString
            }
        )
    }
    
    var body: some View {
        HStack {
            GuestIconView(guest: guest)
                .frame(width: 40, height: 40)
            
            if !isEditing {
                Text(guest.name)
                    .font(.system(size: 18))
                    .foregroundStyle(Color.themeContrast)
            } else {
                TextField("Nom", text: $guest.name)
                    .font(.system(size: 18))
                    .textFieldStyle(.roundedBorder)
                    .focused($nameFieldFocused)
                    .onAppear { nameFieldFocused = true }
                    .onSubmit { stopEditing() }
                
                ColorPicker("Couleur", selection: colorBinding, supportsOpacity: false)
                    .labelsHidden()
            }
            
            Spacer()
            
            if isHovering && !isEditing {
                Button {
                    startEditing()
                } label: {
                    Image(systemName: "pencil.circle")
                        .font(.system(size: 22, weight: .light))
                        .foregroundStyle(Color.themeContrast.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
            
            if isEditing {
                Button {
                    stopEditing()
                } label: {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 22, weight: .light))
                        .foregroundStyle(Color.themeContrast.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
            
            if isHovering || isEditing {
                Button {
                    deleteAction()
                } label: {
                    Image(systemName: "trash.circle")
                        .font(.system(size: 22, weight: .light))
                        .foregroundStyle(Color.themeContrast.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
        }
        .onHover { hover in
            isHovering = hover
        }
    }
}

#Preview {
    GuestListLineView(
        guest: Guest(name: "Mickael", colorHex: "4076f5"),
        deleteAction: {},
        isEditing: false,
        startEditing: {},
        stopEditing: {})
        .frame(width: 400, height: 60)
}
