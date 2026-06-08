//
//  CustomLabel.swift
//  Popote
//
//  Created by Mickael on 02/05/2026.
//

import SwiftUI

struct IngredientCustomLabel: View {
    
    let title:String
    var newTitleAction: ((String) -> Void)?
    var deleteAction: () -> Void
    
    @State private var isEditing: Bool = false
    @State private var newName: String = ""
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
            } else {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            
            Spacer()
            
            if newTitleAction != nil {
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
        .foregroundStyle(Color.themeContrast)
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
