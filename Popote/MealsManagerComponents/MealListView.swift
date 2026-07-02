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
    
    let selectMeal: (MealItem) -> Void
    
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
                        selectMeal(meal)
                    }
            }
            .padding(.top, 0)
            .padding(.bottom, 20)
        }
        .background(
            Color.white
        )
        .background {
//            KeyEventView { event in
//                switch event.keyCode {
//                case 126: // flèche haut
//                    selectedMeal = previousFilteredMeal(
//                        selectedMeal: selectedMeal,
//                        from: filteredMeals
//                    )
//                    return true
//                    
//                case 125: // flèche bas
//                    selectedMeal = nextFilteredMeal(
//                        selectedMeal: selectedMeal,
//                        from: filteredMeals
//                    )
//                    return true
//                    
//                default:
//                    return false
//                }
//            }
//            .frame(width: 0, height: 0)
        }
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
    
    func previousFilteredMeal(selectedMeal: MealItem?, from meals: [MealItem]) -> MealItem? {
        guard !meals.isEmpty else { return nil }
        
        guard let selectedMeal,
              let index = meals.firstIndex(of: selectedMeal)
        else {
            return meals.last
        }
        
        guard index > meals.startIndex else {
            return meals.first
        }
        
        return meals[meals.index(before: index)]
    }

    func nextFilteredMeal(selectedMeal: MealItem?, from meals: [MealItem]) -> MealItem? {
        guard !meals.isEmpty else { return nil }
        
        guard let selectedMeal,
              let index = meals.firstIndex(of: selectedMeal)
        else {
            return meals.first
        }
        
        let nextIndex = meals.index(after: index)
        
        guard nextIndex < meals.endIndex else {
            return meals.last
        }
        
        return meals[nextIndex]
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
            selectMeal: { selectedMeal = $0 },
            addMeal: {}
        )
    }
}
