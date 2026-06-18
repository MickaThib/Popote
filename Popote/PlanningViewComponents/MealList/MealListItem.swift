//
//  MealListItem.swift
//  Popote
//
//  Created by Mickael on 01/05/2026.
//

import SwiftUI

struct MealListItem: View {
    
    @Environment(AppSettings.self) private var appSettings
    
    let meal: MealItem
    
    var body: some View {
        ZStack(alignment: .leading) {
            
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white)
            
            Text(meal.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(appSettings.mainColorContrast)
                .padding(.leading)

        }
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(appSettings.mainColor, lineWidth: 1)
        )
        .frame(height: 30)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MealListItem(meal: MealItem(title: "Quiche lorraine"))
}
