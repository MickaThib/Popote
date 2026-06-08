//
//  GuestGroupView.swift
//  Popote
//
//  Created by Mickael on 31/05/2026.
//

import SwiftUI
import SwiftData

struct GuestGroupView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    let guestsGroup: GuestsGroup
    let deleteAction: () -> Void
    
    private var groupColor: Color {
        Color.init(displayP3Hex: guestsGroup.colorHex)
    }
    
    private var colorBinding: Binding<Color> {
        Binding(
            get: {
                Color(displayP3Hex: guestsGroup.colorHex)
            },
            set: { newColor in
                guestsGroup.colorHex = newColor.displayP3HexString
            }
        )
    }
    
    @State private var isHovering = false
    @State private var isEditing = false
    @State private var newName: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            HStack {
                if isEditing {
                    
                    HStack {
                        TextField(guestsGroup.title, text: $newName)
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(groupColor)
                            .textFieldStyle(.plain)
                            .padding(.horizontal)
                            .focused($isFocused)
                            .onSubmit {
                                commitEdit()
                            }
                            .onChange(of: isFocused) { _, focused in
                                if !focused && isEditing {
                                    commitEdit()
                                }
                            }
                        
                        ColorPicker("Couleur", selection: colorBinding, supportsOpacity: false)
                            .labelsHidden()
                        
                        editDeleteButtons
                    }
                    
                } else {
                    Text(guestsGroup.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(groupColor)
                }
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                Rectangle()
                    .fill(groupColor.opacity(0.1))
                    .stroke(groupColor)
            )
            .overlay(alignment: .trailing) {
                if isHovering && !isEditing {
                    editDeleteButtons
                }
            }
            .onHover { hover in
                isHovering = hover
            }
            
            VStack {
                if guestsGroup.guests.isEmpty {
                    
                    Text("Il n'y a aucun convive\ndans ce groupe")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(groupColor.opacity(0.7))
                        .padding(.bottom, 0.5)
                    Text("Glissez des convives ici")
                        .font(.system(size: 12))
                        .foregroundStyle(groupColor.opacity(0.5))
                    
                } else {
                    let sortedGuestsList = guestsGroup.guests.sorted(by: { $0.name < $1.name })
                    ForEach(sortedGuestsList) { guest in
                        GroupedGuestItem(guest: guest, deleteAction: {
                            guestsGroup.guests.removeAll { $0 == guest }
                            do { try modelContext.save() } catch { print(error) }
                            }
                        )
                            .padding(.horizontal)
                            .background(.white)
                    }
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical)
            .dropDestination(for: GuestTransfer.self,
                             action: handleDrop,
                             //isTargeted: { isTargeted = $0 }
            )
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(groupColor)
        }
        
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var editDeleteButtons: some View {
        HStack(spacing: 4) {
            
            Button {
                if isEditing {
                    commitEdit()
                    isEditing = false
                } else {
                    isEditing = true
                    isFocused = true
                }
                
            } label: {
                Image(systemName: "pencil")
                    .foregroundStyle(groupColor)
                    .font(.system(size: 16, weight: .light))
            }
            
            Button {
                deleteAction()
            } label: {
                Image(systemName: "xmark.circle")
                    .foregroundStyle(groupColor)
                    .font(.system(size: 16, weight: .light))
                    .padding(.trailing, 8)
            }
        }
        .buttonStyle(.plain)
    }
    
    private func commitEdit() {
        guard !newName.isEmpty else { return }
        guestsGroup.title = newName
        isEditing = false
    }
    
    private func handleDrop(_ transfers: [GuestTransfer], _ location: CGPoint) -> Bool {
        for transfer in transfers {
            guard let guest = modelContext.model(for: transfer.persistentID) as? Guest else {
                print("Guest introuvable")
                continue
            }
            
            if guestsGroup.guests.contains(guest) { continue }
            guestsGroup.guests.append(guest)
        }
        
        do { try modelContext.save() } catch { print(error) }
        return true
    }
}

struct GroupedGuestItem: View {
    
    let guest: Guest
    let deleteAction: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack {
            GuestIconView(guest: guest)
                .frame(width: 35, height: 35)
            Text(guest.name)
                .font(.system(size: 14))
            Spacer()
            
            if isHovering {
                Button {
                    deleteAction()
                } label: {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 14))
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
    let guestsGroup = GuestsGroup(title: "Mini tribu", colorHex: "CC1067", guests: [
        Guest(name: "Mickael", colorHex: "3b56cc"),
        Guest(name: "Erwann", colorHex: "121256"),
        Guest(name: "Eliott", colorHex: "ccaa00"),
        Guest(name: "Soline", colorHex: "ff0055")
    ])
    GuestGroupView(guestsGroup: guestsGroup, deleteAction: {})
        .frame(width: 200)
    GuestGroupView(guestsGroup: GuestsGroup(title: "Kidz", colorHex: "4020BB"), deleteAction: {})
        .frame(width: 200)
}
