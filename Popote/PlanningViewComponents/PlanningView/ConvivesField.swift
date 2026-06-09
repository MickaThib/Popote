//
//  ConvivesField.swift
//  Popote
//
//  Created by THIBOURET  Mickael on 04/06/2026.
//

import SwiftUI
import SwiftData

struct ConvivesField: View {
    @Environment(\.modelContext) private var modelContext

    let day: Date
    let slot: MealSlot
    let plannedMeals: [PlannedMeal]
    let allGuests: [Guest]
    let allGroups: [GuestsGroup]
    let planningViewModel: PlanningViewModel

    /// Largeur allouée par PlanningMealFrame après calcul de répartition
    let allocatedWidth: CGFloat
    /// true si les chips doivent scroller (dépassement du seuil 70%)
    let shouldScroll: Bool
    /// Binding pour remonter la largeur naturelle des chips vers PlanningMealFrame
    @Binding var chipsNaturalWidth: CGFloat

    private var selectedGuests: [Guest] {
        unique(plannedMeals.flatMap(\.guests))
    }

    private var selectedGroups: [GuestsGroup] {
        unique(plannedMeals.flatMap(\.guestsGroups))
    }

    var body: some View {
        HStack(spacing: 6) {
            if shouldScroll {
                ScrollView(.horizontal, showsIndicators: false) {
                    chipsContent
                        .fixedSize(horizontal: true, vertical: false)
                }
                .frame(width: allocatedWidth)
            } else {
                chipsContent
                    .fixedSize(horizontal: true, vertical: false)
            }

            menuButton
        }
        .frame(height: 20)
        // Fantôme de mesure : ne perturbe pas le layout
        .overlay(alignment: .leading) {
            chipsContent
                .fixedSize(horizontal: true, vertical: false)
                .hidden()
                .background(
                    GeometryReader { g in
                        Color.clear.preference(key: ChipsWidthKey.self, value: g.size.width)
                    }
                )
        }
        .onPreferenceChange(ChipsWidthKey.self) { w in
            chipsNaturalWidth = w
        }
    }

    @ViewBuilder
    private var chipsContent: some View {
        if selectedGroups.isEmpty && selectedGuests.isEmpty {
            Text("Ajouter des convives")
                .font(.callout)
                .foregroundStyle(slot.color())
                .padding(.horizontal, 6)
        } else {
            HStack(spacing: 6) {
                ForEach(selectedGuests) { guest in
                    chipView(title: guest.name, color: Color(displayP3Hex: guest.colorHex)) {
                        removeGuest(guest)
                    }
                }
                ForEach(selectedGroups) { group in
                    chipView(title: group.title, color: Color(displayP3Hex: group.colorHex)) {
                        removeGroup(group)
                    }
                }
            }
        }
    }

    private var availableGuests: [Guest] {
        allGuests.filter { guest in
            !selectedGuests.contains { $0.persistentModelID == guest.persistentModelID }
        }
    }

    private var availableGroups: [GuestsGroup] {
        allGroups.filter { group in
            !selectedGroups.contains { $0.persistentModelID == group.persistentModelID }
        }
    }

    private var menuButton: some View {
        Menu {
            Section("Groupes") {
                if availableGroups.isEmpty {
                    Text("Aucun groupe")
                } else {
                    ForEach(availableGroups) { group in
                        Button { addGroup(group) } label: { Text(group.title) }
                    }
                }
            }
            Section("Convives") {
                if availableGuests.isEmpty {
                    Text("Aucun convive")
                } else {
                    ForEach(availableGuests) { guest in
                        Button { addGuest(guest) } label: { Text(guest.name) }
                    }
                }
            }
        } label: {
            Image(systemName: "plus.circle")
                .imageScale(.large)
        }
        .menuStyle(.borderlessButton)
        .tint(slot.color())
        .fixedSize(horizontal: true, vertical: false)
    }

    private func addGuest(_ guest: Guest) {
        let meals = planningViewModel.ensurePlannedMeal(
            date: day, slot: slot,
            existingPlannedMeals: plannedMeals,
            modelContext: modelContext
        )
        for plannedMeal in meals {
            if !plannedMeal.guests.contains(where: { $0.persistentModelID == guest.persistentModelID }) {
                plannedMeal.guests.append(guest)
            }
        }
        try? modelContext.save()
    }

    private func addGroup(_ group: GuestsGroup) {
        let meals = planningViewModel.ensurePlannedMeal(
            date: day, slot: slot,
            existingPlannedMeals: plannedMeals,
            modelContext: modelContext
        )
        for plannedMeal in meals {
            if !plannedMeal.guestsGroups.contains(where: { $0.persistentModelID == group.persistentModelID }) {
                plannedMeal.guestsGroups.append(group)
            }
        }
        try? modelContext.save()
    }

    private func removeGuest(_ guest: Guest) {
        for plannedMeal in plannedMeals {
            plannedMeal.guests.removeAll { $0.persistentModelID == guest.persistentModelID }
        }
        try? modelContext.save()
    }

    private func removeGroup(_ group: GuestsGroup) {
        for plannedMeal in plannedMeals {
            plannedMeal.guestsGroups.removeAll { $0.persistentModelID == group.persistentModelID }
        }
        try? modelContext.save()
    }

    private func unique<T: PersistentModel>(_ items: [T]) -> [T] {
        var seen = Set<PersistentIdentifier>()
        return items.filter { seen.insert($0.persistentModelID).inserted }
    }
}

// MARK: - chipView

struct chipView: View {

    let title: String
    let color: Color
    let remove: () -> Void
    @State private var isHovering: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .fontWeight(.medium)

            if isHovering {
                Button { remove() } label: {
                    Image(systemName: "xmark.circle")
                }
                .buttonStyle(.plain)
            }
        }
        .font(.system(size: 11))
        .textCase(.uppercase)
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .frame(height: 20)
        .background {
            RoundedRectangle(cornerRadius: 5).fill(color.mix(with: .white, by: 0.8))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 5).strokeBorder(color, lineWidth: 1)
        }
        .onHover { isHovering = $0 }
    }
}

// MARK: - PreferenceKey

struct ChipsWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Preview

#Preview {
    let group = GuestsGroup(title: "Tribu", colorHex: "669966")

    ConvivesField(
        day: Date(), slot: .evening,
        plannedMeals: [],
        allGuests: [], allGroups: [group],
        planningViewModel: PlanningViewModel(),
        allocatedWidth: 210,
        shouldScroll: false,
        chipsNaturalWidth: .constant(0)
    )

    ConvivesField(
        day: Date(), slot: .evening,
        plannedMeals: [PlannedMeal(date: Date(), slot: .evening, position: 1, guestsGroups: [group])],
        allGuests: [], allGroups: [group],
        planningViewModel: PlanningViewModel(),
        allocatedWidth: 210,
        shouldScroll: false,
        chipsNaturalWidth: .constant(0)
    )
}
