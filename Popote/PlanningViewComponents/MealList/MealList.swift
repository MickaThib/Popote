//
//  MealList.swift
//  Popote
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
            .foregroundStyle(Color.white)
            .frame(height: 45)
            .background(
                Color.theme
            )
                        
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MealItem.self, configurations: config)
    
    let meals = [
        MealItem(title: "Pâtes carbo"),
        MealItem(title: "Pizza maison"),
        MealItem(title: "Quiche aux poireaux"),
        MealItem(title: "Lasagnes"),
        MealItem(title: "Cordon bleu")
    ]
    
    for meal in meals { container.mainContext.insert(meal) }
    
    return MealList()
        .modelContainer(container)
}
