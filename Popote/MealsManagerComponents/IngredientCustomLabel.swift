//
//  CustomLabel.swift
//  Popote
//
//  Created by Mickael on 02/05/2026.
//

import SwiftUI

struct IngredientCustomLabel: View {
    
    @Environment(AppSettings.self) private var appSettings
    
    let title:String
    var newTitleAction: ((String) -> Void)?
    var deleteAction: () -> Void
    
    @State private var isEditing: Bool = false
    @State private var newName: String = ""
    @State private var isHovering: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        
        HStack {
            if isEditing {
                TextField(title, text: $newName)
                    .focused($isFocused)
                    .onSubmit { commitEdit() }
                    .onChange(of: isFocused) { _, focused in
                        if !focused && isEditing {
                            commitEdit()
                        }
                    }
                    .padding(.bottom, 1)
            } else {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .onTapGesture {
                        newName = title
                        isEditing = true
                        isFocused = true
                    }
            }
            
            Spacer()
            
            if newTitleAction != nil {
                if isHovering && !isEditing {
                    Button {
                        if isEditing {
                            commitEdit()
                        } else {
                            newName = title
                            isEditing = true
                            isFocused = true
                        }
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                    
                } else if isEditing {
                    
                    Button {
                        commitEdit()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }
            }
            Button {
                deleteAction()
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(.plain)
            .padding(.trailing)
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(appSettings.mainColorContrast)
        .onHover { hover in
            isHovering = hover
        }
    }
    
    private func commitEdit() {
        guard !newName.isEmpty else { return }
        newTitleAction?(newName)
        isEditing = false
    }
    
}

#Preview {
    IngredientCustomLabel(title: "Côtes de porc", deleteAction: {})
}
