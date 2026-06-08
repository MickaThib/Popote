//
//  IngredientAddSheet.swift
//  Popote
//
//  Created by Mickael on 07/05/2026.
//

import SwiftUI

struct IngredientAddSheet: View {

    @Environment(\.dismiss) private var dismiss

    let existingIngredients: [Ingredient]
    let onAdd: (String) -> Void

    @State private var ingredientName = ""
    @State private var showDuplicateConfirmation = false

    @FocusState private var isTextFieldFocused: Bool

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("Nouvel ingrédient")
                .font(.title2)
                .fontWeight(.semibold)

            TextField("Nom de l’ingrédient", text: $ingredientName)
                .textFieldStyle(.roundedBorder)
                .focused($isTextFieldFocused)
                .onSubmit {
                    handleAdd()
                }

            HStack {

                Spacer()

                Button("Annuler") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Ajouter") {
                    handleAdd()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(cleanedName.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 420)

        .confirmationDialog(
            "Cet ingrédient existe déjà",
            isPresented: $showDuplicateConfirmation,
            titleVisibility: .visible
        ) {

            Button("Ajouter quand même") {

                showDuplicateConfirmation = false

                DispatchQueue.main.async {
                    confirmAdd()
                }
            }

            Button("Annuler", role: .cancel) { }

        } message: {

            Text("Voulez-vous vraiment ajouter un doublon ?")
        }

        .onAppear {

            DispatchQueue.main.async {
                isTextFieldFocused = true
            }
        }
    }
}

// MARK: - Logic

private extension IngredientAddSheet {

    var cleanedName: String {

        ingredientName
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func handleAdd() {

        guard !cleanedName.isEmpty else {
            return
        }

        if ingredientExists(cleanedName) {

            showDuplicateConfirmation = true

        } else {

            confirmAdd()
        }
    }

    func confirmAdd() {

        onAdd(cleanedName)
        dismiss()
    }

    func ingredientExists(_ name: String) -> Bool {

        func normalize(_ string: String) -> String {

            string
                .folding(
                    options: [.caseInsensitive, .diacriticInsensitive],
                    locale: .current
                )
                .replacingOccurrences(
                    of: "\\s+",
                    with: "",
                    options: .regularExpression
                )
        }

        return existingIngredients.contains {
            normalize($0.name) == normalize(name)
        }
    }
}
