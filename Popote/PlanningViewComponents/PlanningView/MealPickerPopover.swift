//
//  MealPickerPopover.swift
//  Popote
//
//  Created by Mickael on 17/05/2026.
//

import SwiftUI
import SwiftData

struct MealPickerPopover: View {
    
    let meals: [MealItem]
    let onSelect: (MealItem) -> Void
    @State private var hoveredMealID: MealItem.ID?
    
    @State var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    
    var filteredMeals: [MealItem] {
        if searchText.isEmpty {
            meals
        } else {
            meals.filter {
                $0.title.localizedStandardContains(searchText)
            }
        }
    }
    
    var body: some View {
        
        if meals.isEmpty {
            VStack {
                Spacer()
                Text("Aucun repas enrgistré")
                    .font(.headline)
                Text("Ajoutez des repas\ndans l'onglet \"Repas\"")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(.vertical)
            .padding(.horizontal, 20)
        } else {
            
            VStack(spacing: 1){
                TextField("Rechercher", text: $searchText)
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
                
                
                List(filteredMeals) { meal in
                    Button {
                        onSelect(meal)
                    } label: {
                        HStack {
                            Text(meal.title)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.themeContrast)
                            
                            Spacer()
                        }
                        .padding(.vertical, 7)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(hoveredMealID == meal.id ? Color.theme.opacity(0.2) : Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.theme)
                        )
                        .onHover { hover in
                            hoveredMealID = hover ? meal.id : nil
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                }
            }
            .frame(width: 300, height: 350)
        }
    }
}

#Preview {
    let meals = [
        MealItem(title: "Pâtes carbo"),
        MealItem(title: "Spaghetti bolognaise"),
        MealItem(title: "Quiche lorraine"),
        
    ]
    MealPickerPopover(meals: meals, onSelect: {_ in })
}
