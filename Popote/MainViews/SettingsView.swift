//
//  SettingsView.swift
//  Popote
//
//  Created by THIBOURET  Mickael on 17/06/2026.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var firstDay: Weekday = .friday
    @State var numberOfDaysInPlanning: DaysInPlanning = .eightDays
    @State var mainColor: Color = .purple
    @State var secondaryColor: Color = .orange
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Réglages")
                .font(.system(.title, design: .rounded))
                .padding(.horizontal)
                .padding(.top)
            
            Divider()
            
            Form {
                Section(header: Text("Préférences")) {
                    Picker(selection: $firstDay) {
                        ForEach(Weekday.allCases, id: \.self) { day in
                            Text(day.string)
                        }
                    } label: {
                        Text("Premier jour de la semaine")
                    }

                    Picker(selection: $numberOfDaysInPlanning) {
                        ForEach(DaysInPlanning.allCases) { days in
                            Text(days.label).tag(days)
                        }
                    } label: {
                        Text("Nombre de jours à afficher")
                    }
                    .pickerStyle(.segmented)
                    
                    //Text("Choix : \(numberOfDaysInPlanning.rawValue)")
                }
                Section(header: Text("Interface")) {
                    ColorPicker("Couleur principale", selection: $mainColor)
                    ColorPicker("Couleur secondaire", selection: $secondaryColor)
                }
            }
            .formStyle(.grouped)
            
            Spacer()
            
            
            HStack {
                Spacer()
                Button("Valider") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

enum DaysInPlanning: Int, CaseIterable, Identifiable {
    
    case sevenDays = 7
    case eightDays = 8
    
    var id: Int {
        rawValue
    }
    
    var label: String {
        switch self {
        case .sevenDays:
            return "7 jours"
        case .eightDays:
            return "8 jours"
        }
    }
}

#Preview {
    SettingsView()
}
