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
    
    @State var isSearchFieldVisible: Bool = false
    @State var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    
    var filteredMeals: [MealItem] {
        if searchText.isEmpty {
            mealList
        } else {
            mealList.filter {
                $0.title.localizedStandardContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack (spacing: 0) {
            HStack (alignment: .firstTextBaseline) {
                Text("Mes repas")
                    .font(.system(size: 22))
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                Spacer()
                Button {
                    if isSearchFieldVisible {
                        isSearchFocused = false
                        searchText = ""
                        
                        withAnimation {
                            isSearchFieldVisible = false
                        }
                    } else {
                        withAnimation {
                            isSearchFieldVisible = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            isSearchFocused = true
                        }
                    }
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
            
            if isSearchFieldVisible {
                TextField("Rechercher un repas", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .focused($isSearchFocused)
                        .padding(.horizontal)
                        .padding(.top)
                        .overlay(alignment: .trailing) {
                            if !searchText.isEmpty || isSearchFocused {
                                Button {
                                    if searchText.isEmpty {
                                        isSearchFocused = false
                                    } else {
                                        searchText = ""
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                                .padding(.top)
                                .padding(.trailing, 25)
                            }
                        }
            }
            
            if mealList.isEmpty {
                VStack {
                    Spacer()
                    Text("Aucun repas enrgistré")
                        .font(.headline)
                    Text("Ajoutez des repas dans l'onglet \"Repas\"")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                    
            } else {
                
                List {
                    ForEach(filteredMeals) { meal in
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
