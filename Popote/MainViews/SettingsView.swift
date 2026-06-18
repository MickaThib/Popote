//
//  SettingsView.swift
//  Popote
//
//  Created by THIBOURET  Mickael on 17/06/2026.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(AppSettings.self) private var appSettings
    @Environment(\.dismiss) var dismiss
    @State var firstDay: Weekday = .friday
    @State var numberOfDaysInPlanning: DaysInPlanning = .eightDays
    
    var body: some View {
        
        @Bindable var appSettings = appSettings
        
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
                    
                    ColorPicker(
                        "Couleur principale",
                        selection: Binding(
                            get: { Color(displayP3Hex: appSettings.mainColorHex) },
                            set: { newColor in
                                appSettings.mainColorHex = newColor.displayP3HexString
                        })
                    )
                    
                    ColorPicker(
                        "Couleur secondaire",
                        selection: Binding(
                            get: { Color(displayP3Hex: appSettings.secondaryColorHex) },
                            set: { newColor in
                                appSettings.secondaryColorHex = newColor.displayP3HexString
                        })
                    )
                    
                    Button("Réinitialiser les couleurs") {
                        appSettings.mainColorHex = "#6762A4"
                        appSettings.secondaryColorHex = "#FA8070"
                    }
                    .buttonStyle(.borderless)
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
