//
//  PlanningMealFrame.swift
//  Repascope
//
//  Created by Mickael Thibouret on 30/04/2026.
//

import SwiftUI

struct PlanningMealFrame: View {
    
    let day: Date
    let moment: MealMoment
    @State var guests: String = ""
    @State var notes: String = ""
    @State var meal1: MealItem?
    @State var meal2: MealItem?
    
    var body: some View {
        VStack {
            HStack {
                TextField("Convives", text: $guests)
                    .textFieldStyle(.plain)
                TextField("Notes", text: $notes)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 7)
            .padding(.top, 7)
            
            if let meal1 = meal1 {
                
                if let meal2 = meal2 {
                    // Si deux repas sont prévus : répartir case à égalité
                    HStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.blue.opacity(0.2))
                            .frame(minHeight: 40, maxHeight: .infinity)
                            .overlay {
                                Text(meal1.title)
                                    .font(.headline)
                            }
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.blue.opacity(0.2))
                            .frame(minHeight: 40, maxHeight: .infinity)
                            .overlay {
                                Text(meal2.title)
                                    .font(.headline)
                            }
                    }
                    .padding(.horizontal, 7)
                    .padding(.bottom, 7)
                    
                } else {
                    // Si un seul repas est prévu : prévoir espace pour en ajouter un autre
                    HStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.blue.opacity(0.2))
                            .frame(minHeight: 40, maxHeight: .infinity)
                            .overlay {
                                Text(meal1.title)
                                    .font(.headline)
                            }
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.clear)
                            .stroke(Color.gray.opacity(0.2))
                            .frame(maxWidth: 40)
                            .overlay {
                                Image(systemName: "plus")
                            }
                    }
                    .padding(.horizontal, 7)
                    .padding(.bottom, 7)
                }
                
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray.opacity(0.2))
                    .frame(minHeight: 40, maxHeight: .infinity)
                    .padding(.horizontal, 7)
                    .padding(.bottom, 7)
                    .overlay {
                        Text("Aucun repas prévu")
                            .font(.callout)
                            .foregroundStyle(.gray)
                    }
            }
        }
        .frame(minWidth: 150, maxWidth: .infinity)
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray)
        }
    }
}

enum MealMoment:String {
    case noon = "Midi"
    case evening = "Soir"
}

#Preview {
    let meal1 = MealItem(title: "Quiche lorraine", photo: nil)
    let meal2 = MealItem(title: "Haricots verts", photo: nil)
    PlanningMealFrame(day: Date(), moment: .noon, meal1: meal1)
}
