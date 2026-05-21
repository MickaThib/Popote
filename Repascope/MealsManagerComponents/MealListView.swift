//
//  MealsManagerList.swift
//  Repascope
//
//  Created by Mickael Thibouret on 04/05/2026.
//

import SwiftUI
import SwiftData

struct MealListView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \MealItem.title) private var meals: [MealItem]
    
    @Binding var selectedMeal: MealItem?
    @State var showDeleteAlert: Bool = false
    @State private var mealToDelete: MealItem?
    
    let addMeal: () -> Void
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack(alignment: .lastTextBaseline) {
                
                Text("Mes repas")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.theme)

                Spacer()
                
                Button {
                    addMeal()
                } label: {
                    Label("Ajouter", systemImage: "plus")
                }
                .padding(.trailing)
                .buttonStyle(.borderless)
            }
            .padding(.horizontal)
            .padding(.top)
            
            //TODO: Recherche
            TextField("Rechercher", text: .constant(""))
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 1)
            
            List(meals, id: \.id) { meal in
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
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)
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
        MealItem(title: "Raclette", photo: nil, ingredients: []),
        MealItem(title: "Hamburger maison", photo: nil, ingredients: []),
        MealItem(title: "Hot dogs", photo: nil, ingredients: []),
        MealItem(title: "Poisson pané", photo: nil, ingredients: []),
        MealItem(title: "Quiche lorraine", photo: nil, ingredients: []),
        MealItem(title: "Lasagnes", photo: nil, ingredients: [])
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
