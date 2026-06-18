//
//  CustomLabel.swift
//  Popote
//
//  Created by Mickael on 02/05/2026.
//

import SwiftUI

struct MealCustomLabel: View {
    
    @Environment(AppSettings.self) private var appSettings
    
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
                .fill(isSelected ? appSettings.mainColor.opacity(0.2) : appSettings.mainColor.opacity(0.1))
                .stroke(isSelected ? appSettings.mainColor : .clear, lineWidth: 1)
            
            HStack {
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(appSettings.mainColor)
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
