//
//  EditMealView.swift
//  Repascope
//
//  Created by Mickael Thibouret on 05/05/2026.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct EditMealView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Ingredient.name) private var ingredients: [Ingredient]

    
    @Bindable var meal: MealItem
    @Binding var startEditing: Bool
        
    var body: some View {
        VStack {
            
            // Photo
            PhotoView(meal: meal)
            
            ScrollView {
                
                EditMealTextField(startEditing: $startEditing, meal: meal)
                .frame(maxWidth: 500)
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text("Ingrédients")
                        .font(.headline)
                        .foregroundStyle(Color.themeContrast)
                    
                    EditMealIngredientList(meal: meal, ingredients: ingredients)
                    .frame(maxWidth: .infinity, minHeight: 80)
                    
                    
                    Text("Notes")
                        .font(.headline)
                        .foregroundStyle(Color.themeContrast)
                    
                    TextField("Ajouter des notes...", text: $meal.notes, axis: .vertical)
                        .lineLimit(5...10)
                }
                .frame(maxWidth: 500)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .frame(minWidth: 600)
        .background(
            Color.white
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct PhotoView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    let meal: MealItem
    @State private var showImporter = false
    @State private var isHovering = false
    @State private var showDeleteImageAlert = false
    
    var body: some View {
        
        VStack {
            if let photoData = meal.imageData,
               let nsImage = NSImage(data: photoData){
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipped()
            } else {
                VStack {
                    Image(systemName: "camera")
                        .font(.system(size: 50))
                        .onTapGesture {
                            showImporter = true
                        }
                    
                    Button("Ajouter une image") {
                        showImporter = true
                    }
                    .buttonStyle(.plain)
                    
                }
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .contentShape(RoundedRectangle(cornerRadius: 10))
                .background(Color.theme.opacity(0.5))
            }
        }
        .overlay(alignment: .topTrailing) {
            if isHovering && meal.imageData != nil {
                Button {
                    showDeleteImageAlert = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                        .shadow(radius: 5)
                        .padding()
                }
                .buttonStyle(.plain)
            }
        }
        .alert("Supprimer l'image de couverture ?", isPresented: $showDeleteImageAlert, actions: {
            Button(role: .destructive) {
                meal.imageData = nil
                do { try modelContext.save() } catch { print(error) }
            }
            Button(role: .cancel) {}
        })
        .onHover { hover in
            isHovering = hover
        }
        .dropDestination(for: URL.self) { urls, location in
            
            guard let url = urls.first else { return false }
            
            let allowedExtensions = ["jpg", "jpeg", "png", "heic", "webp"]
            guard allowedExtensions.contains(url.pathExtension.lowercased()) else {
                return false
            }
            
            return setImageData(from: url)
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.image]) { result in
            
            switch result {
            case .success(let url):
                _ = setImageData(from: url)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func setImageData(from url: URL) -> Bool {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let data = try Data(contentsOf: url)
            meal.imageData = data
            try modelContext.save()
            return true
        } catch {
            print("Erreur import image :", error)
            return false
        }
    }
}

struct EditMealTextField: View {
    
    @Environment(\.modelContext) private var modelContext

    @State private var isEditing = false
    @Binding var startEditing: Bool
    @FocusState private var titleFocused: Bool
    @Bindable var meal: MealItem
    
    var body: some View {
        HStack {
            if isEditing {
                TextField("Nom de la recette", text: $meal.title)
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.themeContrast)
                    .padding(.vertical, 16)
                    .focused($titleFocused)
                    .onSubmit {
                        isEditing = false
                        try? modelContext.save()
                    }
            } else {
                Text(meal.title)
                    .font(.system(size: 30))
                    .foregroundStyle(Color.theme)
                    .fontWeight(.bold)
                    .padding(.vertical, 20)
            }
            Spacer()
            Button("Modifier", systemImage: "pencil") {
                isEditing.toggle()
                try? modelContext.save()
            }
            .buttonStyle(.borderless)
        }
        .onChange(of: startEditing) { _, newValue in
            if newValue {
                isEditing = true
                startEditing = false
                Task { @MainActor in
                    titleFocused = true  // décaler après le rendu
                }
            }
        }
        .onChange(of: meal) { _, _ in
            isEditing = false
        }
    }
}

struct EditMealIngredientList: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var meal: MealItem
    let ingredients: [Ingredient]
    @State private var isTargeted = false
    @State private var showAddIngredientSheet = false
    
    var body: some View {
        ingredientListContent
            .frame(maxWidth: .infinity)
            .background(backgroundShape)
            .overlay(borderShape)
            .animation(.easeInOut(duration: 0.15), value: isTargeted)
            .dropDestination(
                for: IngredientTransfer.self,
                action: handleDrop,
                isTargeted: { isTargeted = $0 }
            )
            .sheet(isPresented: $showAddIngredientSheet) {

                IngredientAddSheet(
                    existingIngredients: ingredients
                ) { name in
                    let newIngredient = MealIngredient(ingredient: Ingredient(name: name), quantity: 1)
                    meal.ingredients.append(newIngredient)
                    modelContext.insert(newIngredient)
                    do { try modelContext.save() } catch { print(error) }
                }
            }
    }
    
    private var ingredientListContent: some View {
        
        VStack(alignment: .trailing, spacing: 0) {
            if meal.ingredients.isEmpty {
                Text("Glisser des ingrédients ici")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
            } else {
                ingredientsList
                    .padding(.top, 10)
            }
            
            Spacer()
            
            Button {
                showAddIngredientSheet = true
            } label: {
                Image(systemName: "plus.circle")
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(Color.themeContrast)
                    .padding()
            }
            .buttonStyle(.plain)
        }
    }
    
    private var ingredientsList: some View {
        ForEach($meal.ingredients) { $ingredient in
            IngredientStepperLine(
                ingredient: $ingredient,
                onDelete: {
                    deleteIngredient(ingredient)
                }
            )
            .frame(height: 20)
            
            Divider()
        }
    }
    
    private var backgroundShape: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(isTargeted ? Color.theme.opacity(0.1) : Color.theme.opacity(0.05))
    }
    
    private var borderShape: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color.theme, lineWidth: isTargeted ? 2 : 1)
    }
    
    private func deleteIngredient(_ ingredient: MealIngredient) {
        meal.ingredients.removeAll { $0.id == ingredient.id }
        try? modelContext.save()
    }
    
    private func handleDrop(_ transfers: [IngredientTransfer], _ location: CGPoint) -> Bool {
        for transfer in transfers {
            guard let ingredient = modelContext.model(for: transfer.persistentID) as? Ingredient else {
                print("🔴 ingredient introuvable")
                continue
            }
            
            let mealIngredient = MealIngredient(ingredient: ingredient, quantity: 1)
            meal.ingredients.append(mealIngredient)
        }
        
        try? modelContext.save()
        return true
    }
}

#Preview {
    EditMealView(meal: MealItem(title: "Pâtes bolognaises", ingredients: [
        MealIngredient(ingredient: Ingredient(name: "Pâtes"), quantity: 1),
        MealIngredient(ingredient: Ingredient(name: "Sauce tomate"), quantity: 1),
        MealIngredient(ingredient: Ingredient(name: "Viande hachée"), quantity: 1)
    ]), startEditing: .constant(false))
    .frame(height: 800)
}
