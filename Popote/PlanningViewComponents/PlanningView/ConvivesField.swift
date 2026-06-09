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

    private var selectedGuests: [Guest] {
        unique(plannedMeals.flatMap(\.guests))
    }

    private var selectedGroups: [GuestsGroup] {
        unique(plannedMeals.flatMap(\.guestsGroups))
    }

    var body: some View {
        HStack(spacing: 6) {
            
            if selectedGroups.isEmpty && selectedGuests.isEmpty {
                Text("Ajouter des convives")
                    .font(.callout)
                    .foregroundStyle(slot.color())
                    .padding(.horizontal, 6)
                    .fixedSize(horizontal: true, vertical: false)
            } else {
                //ScrollView(.horizontal, showsIndicators: false) {
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
                //}
            }

            Menu {
                Section("Groupes") {
                    if availableGroups.isEmpty {
                        Text("Aucun groupe")
                    } else {
                        ForEach(availableGroups) { group in
                            Button {
                                addGroup(group)
                            } label: {
                                Text(group.title)
                            }
                        }
                    }
                }
                
                Section("Convives") {
                    if availableGuests.isEmpty {
                        Text("Aucun convive")
                    } else {
                        ForEach(availableGuests) { guest in
                            Button {
                                addGuest(guest)
                            } label: {
                                Text(guest.name)
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "plus.circle")
                    .imageScale(.large)
            }
            .menuStyle(.borderlessButton)
            .tint(slot.color().opacity(1))
        }
        .frame(height: 20)
    }

    private var availableGuests: [Guest] {
        allGuests.filter { guest in
            !selectedGuests.contains {
                $0.persistentModelID == guest.persistentModelID
            }
        }
    }

    private var availableGroups: [GuestsGroup] {
        allGroups.filter { group in
            !selectedGroups.contains {
                $0.persistentModelID == group.persistentModelID
            }
        }
    }

    private func addGuest(_ guest: Guest) {
        let meals = planningViewModel.ensurePlannedMeal(
            date: day,
            slot: slot,
            existingPlannedMeals: plannedMeals,
            modelContext: modelContext
        )
        for plannedMeal in meals {
            if !plannedMeal.guests.contains(where: {
                $0.persistentModelID == guest.persistentModelID
            }) {
                plannedMeal.guests.append(guest)
            }
        }

        try? modelContext.save()
    }

    private func addGroup(_ group: GuestsGroup) {
        let meals = planningViewModel.ensurePlannedMeal(
            date: day,
            slot: slot,
            existingPlannedMeals: plannedMeals,
            modelContext: modelContext
        )
        
        for plannedMeal in meals {
            if !plannedMeal.guestsGroups.contains(where: {
                $0.persistentModelID == group.persistentModelID
            }) {
                plannedMeal.guestsGroups.append(group)
            }
        }

        try? modelContext.save()
    }

    private func removeGuest(_ guest: Guest) {
        for plannedMeal in plannedMeals {
            plannedMeal.guests.removeAll {
                $0.persistentModelID == guest.persistentModelID
            }
        }

        try? modelContext.save()
    }

    private func removeGroup(_ group: GuestsGroup) {
        for plannedMeal in plannedMeals {
            plannedMeal.guestsGroups.removeAll {
                $0.persistentModelID == group.persistentModelID
            }
        }

        try? modelContext.save()
    }

    private func unique<T: PersistentModel>(_ items: [T]) -> [T] {
        var seen = Set<PersistentIdentifier>()

        return items.filter { item in
            seen.insert(item.persistentModelID).inserted
        }
    }
}

struct chipView: View {
    
    let title: String
    let color: Color
    let remove: () -> Void
    @State var isHovering: Bool = false
    
    var body: some View {
        
        HStack(spacing: 4) {
            Text(title)
                .fontWeight(.medium)
                .fixedSize(horizontal: true, vertical: false)

            if isHovering {
                Button {
                    remove()
                } label: {
                    Image(systemName: "xmark.circle")
                }
                .buttonStyle(.plain)
            }
        }
        .font(.system(size: 11))
        .textCase(.uppercase)
        .foregroundStyle(color)
        .fixedSize(horizontal: true, vertical: false)
        .padding(.horizontal, 8)
        .frame(height: 20)
        .background {
            RoundedRectangle(cornerRadius: 5).fill(color.mix(with: .white, by: 0.8))
        }
        .overlay { RoundedRectangle(cornerRadius: 5).strokeBorder(color, lineWidth: 1)}
        .onHover { hover in
            isHovering = hover
        }
    }
}

#Preview {
    let group = GuestsGroup(title: "Tribu", colorHex: "669966")
    
    ConvivesField(
        day: Date(),
        slot: .evening,
        plannedMeals: [],
        allGuests: [],
        allGroups: [group],
        planningViewModel: PlanningViewModel()
    )
    
    ConvivesField(
        day: Date(),
        slot: .evening,
        plannedMeals: [PlannedMeal(date: Date(), slot: .evening, position: 1, guestsGroups: [group])],
        allGuests: [],
        allGroups: [group],
        planningViewModel: PlanningViewModel()
    )
}
