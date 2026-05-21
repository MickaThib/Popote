//
//  MealListItem.swift
//  Repascope
//
//  Created by Mickael on 01/05/2026.
//

import SwiftUI

struct MealListItem: View {
    
    let meal: MealItem
    
    var body: some View {
        ZStack(alignment: .leading) {
            
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white)
            
            Text(meal.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.themeContrast)
                .padding(.leading)

        }
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.theme, lineWidth: 1)
        )
        .frame(height: 30)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MealListItem(meal: MealItem(title: "Quiche lorraine", photo: nil))
}
