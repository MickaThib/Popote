//
//  MealList.swift
//  Repascope
//
//  Created by Mickael on 29/04/2026.
//

import SwiftUI
import SwiftData

struct MealList: View {
        
    @Query(sort: \MealItem.title) var mealList: [MealItem]
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            HStack (alignment: .firstTextBaseline) {
                Text("Mes repas")
                    .font(.system(size: 22))
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                Spacer()
                Button {
                    //TODO: Recherche
                } label: {
                    Image(systemName: "magnifyingglass")
                        .padding(.trailing)
                        .font(.system(size: 18))
                }
                .buttonStyle(.plain)

            }
            .foregroundStyle(Color.theme)
            .frame(height: 45)
            
            Divider()
            
            List {
                ForEach(mealList) { meal in
                    MealListItem(meal: meal)
                        .listRowSeparator(.hidden)
                        .draggable(PlanningDropTransfer(persistentID: meal.persistentModelID, kind: .mealItem))
                }
            }
            .listStyle(.plain)
            .safeAreaInset(edge: .top) {
                Color.clear
                    .frame(height: 1)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.bottom)
    }
}

#Preview {
    MealList()
}
