//
//  MealsManagerList.swift
//  Popote
//
//  Created by Mickael Thibouret on 04/05/2026.
//

import SwiftUI
import SwiftData

struct MealListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    
    @Query(sort: \MealItem.title) private var meals: [MealItem]
    
    @Binding var selectedMeal: MealItem?
    @State var showDeleteAlert: Bool = false
    @State private var mealToDelete: MealItem?
    
    @State var searchText: String = ""
    var filteredMeals: [MealItem] {
        if searchText.isEmpty {
            meals
        } else {
            meals.filter {
                $0.title.localizedStandardContains(searchText)
            }
        }
    }
    
    let addMeal: () -> Void
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack(alignment: .lastTextBaseline) {
                
                Text("Mes repas")
                    .font(.system(size: 24, weight: .bold))

                Spacer()
                
                Button {
                    addMeal()
                } label: {
                    Label("Ajouter", systemImage: "plus")
                }
                .padding(.trailing)
                .buttonStyle(.borderless)
            }
            .foregroundStyle(Color.white)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(
                appSettings.mainColor
            )
            
            //MARK: Recherche
            TextField("Rechercher", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 1)
                .overlay(alignment: .trailing) {
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 15)
                        .padding(.trailing, 25)
                    }
                }
            
            List(filteredMeals, id: \.id) { meal in
                MealCustomLabel(
                    title: meal.title,
                    isSelected: selectedMeal === meal, // triple "=" -> Comparaison par référence
                    deleteAction: {
                        mealToDelete = meal
                        showDeleteAlert = true
                    }
                )
                    .listRowSeparator(.hidden)
                    .frame(height: 30)
                    .onTapGesture {
                        selectedMeal = meal
                    }
            }
            .padding(.top, 0)
            .padding(.bottom, 20)
        }
        .background(
            Color.white
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 10)
        )
        .alert("Supprimer \(mealToDelete?.title ?? "ce repas") ?", isPresented: $showDeleteAlert) {
            Button("Annuler", role: .cancel){
                mealToDelete = nil
            }
            Button("Supprimer", role: .destructive){
                if let meal = mealToDelete {
                    
                    for plannedMeal in meal.plannedMeals {
                        modelContext.delete(plannedMeal)
                    }
                    
                    modelContext.delete(meal)
                    
                    do {
                        try modelContext.save()
                    } catch {
                        print("Erreur suppression MealItem", error)
                    }
                    
                    if selectedMeal === meal {
                        selectedMeal = nil
                    }
                }
                mealToDelete = nil
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: MealItem.self,
        configurations: config
    )

    let meals = [
        MealItem(title: "Raclette", ingredients: []),
        MealItem(title: "Hamburger maison", ingredients: []),
        MealItem(title: "Hot dogs", ingredients: []),
        MealItem(title: "Poisson pané", ingredients: []),
        MealItem(title: "Quiche lorraine", ingredients: []),
        MealItem(title: "Lasagnes", ingredients: [])
    ]

    for meal in meals {
        container.mainContext.insert(meal)
    }

    return MealListViewPreviewWrapper()
        .modelContainer(container)
}

private struct MealListViewPreviewWrapper: View {
    @State private var selectedMeal: MealItem?

    var body: some View {
        MealListView(
            selectedMeal: $selectedMeal,
            addMeal: {}
        )
    }
}
