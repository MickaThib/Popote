//
//  NoMealSelectedView.swift
//  Repascope
//
//  Created by Mickael Thibouret on 21/05/2026.
//

import SwiftUI

struct NoMealSelectedView: View {
    var body: some View {
        VStack {
            Text("Aucun repas sélectionné")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
    }
}

#Preview {
    NoMealSelectedView()
}
