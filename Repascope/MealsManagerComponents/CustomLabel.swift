//
//  CustomLabel.swift
//  Repascope
//
//  Created by Mickael on 02/05/2026.
//

import SwiftUI

struct CustomLabel: View {
    
    let title:String
    let type: ListLabelType
    let isSelected: Bool
    var newTitleAction: ((String) -> Void)?
    var deleteAction: () -> Void
    
    @State private var isEditing: Bool = false
    @State private var newName: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            
            RoundedRectangle(cornerRadius: 5)
                .fill(isSelected ? type.ItemColor().opacity(0.3) : type.ItemColor().opacity(0.2))
                .stroke(isSelected ? type.ItemColor() : .clear, lineWidth: 1)
            
            HStack {
                if isEditing {
                    TextField(title, text: $newName)
                        .padding(.leading)
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
                        .foregroundStyle(.black)
                        .padding(.leading)
                }
                
                Spacer()
                
                if type == .ingredient, newTitleAction != nil {
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
            
        }
        .frame(maxWidth: .infinity)
    }
    
    private func commitEdit() {
            guard !newName.isEmpty else { return }
            newTitleAction?(newName)
            isEditing = false
        }
    
}

enum ListLabelType: String {
    case ingredient = "Ingrédients"
    case meal = "Plats"
    
    func ItemColor() -> Color {
        switch self {
        case .ingredient:
            return Color.noon
        case .meal:
            return Color.theme
        }
    }
}

#Preview {
    CustomLabel(title: "Côtes de porc", type: .ingredient, isSelected: true, deleteAction: {})
}
