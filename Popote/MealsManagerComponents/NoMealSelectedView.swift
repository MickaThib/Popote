//
//  NoMealSelectedView.swift
//  Popote
//
//  Created by Mickael Thibouret on 21/05/2026.
//

import SwiftUI

struct NoMealSelectedView: View {
    var body: some View {
        VStack {
            Image("chef")
                .resizable()
                .scaledToFit()
                .frame(width: 300)
            
            Text("Aucun repas sélectionné")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color.theme)
                .padding(.top, 10)
                .padding(.bottom, 2)
            
            HStack {
                Image(systemName: "arrow.left")
                    .font(.system(size: 14))
                Text("Sélectionnez un repas dans la colonne de gauche")
            }
            .foregroundStyle(Color.theme.opacity(0.7))
        }
        .frame(minWidth: 400, maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: Color.theme.opacity(0.3),radius: 6, x: 5, y: 5)
        )
    }
}

#Preview {
    NoMealSelectedView()
}
