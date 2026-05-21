//
//  CustomLabel.swift
//  Repascope
//
//  Created by Mickael on 02/05/2026.
//

import SwiftUI

struct MealCustomLabel: View {
    
    let title:String
    let isSelected: Bool
    var newTitleAction: ((String) -> Void)?
    var deleteAction: () -> Void
    
    @State private var isEditing: Bool = false
    @State private var newName: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            
            RoundedRectangle(cornerRadius: 5)
                .fill(isSelected ? Color.theme.opacity(0.2) : Color.theme.opacity(0.1))
                .stroke(isSelected ? Color.theme : .clear, lineWidth: 1)
            
            HStack {
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.theme)
                    .padding(.leading)
                
                Spacer()
                
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
}

#Preview {
    MealCustomLabel(title: "Côtes de porc", isSelected: true, deleteAction: {})
}
