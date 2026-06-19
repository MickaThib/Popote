//
//  SettingsView.swift
//  Popote
//
//  Created by THIBOURET  Mickael on 17/06/2026.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(AppSettings.self) private var appSettings
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("PlanningFirstDay") private var planningFirstDayRawValue: Int = Weekday.friday.rawValue
    @AppStorage("NumberOfDaysInPlanning") private var numberOfDaysInPlanningRawValue: Int = DaysInPlanning.eightDays.rawValue
    @AppStorage("ShoppingDay") private var shoppingDayRawValue: Int = Weekday.saturday.rawValue
    @AppStorage("ShoppingDayMoment") private var shoppingDayMomentRawValue: Int = ShoppingMoment.morning.rawValue
    
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
                    Picker(selection: planningFirstDayBinding) {
                        ForEach(Weekday.allCases) { day in
                            Text(day.string).tag(day)
                        }
                    } label: {
                        Text("Premier jour de la semaine")
                    }
                    
                    Picker(selection: numberOfDaysInPlanningBinding) {
                        ForEach(DaysInPlanning.allCases) { days in
                            Text(days.label).tag(days)
                        }
                    } label: {
                        Text("Nombre de jours à afficher")
                    }
                    .pickerStyle(.segmented)
                    
                    Picker(selection: shoppingDayBinding) {
                        ForEach(Weekday.allCases) { day in
                            Text(day.string).tag(day)
                        }
                    } label: {
                        Text("Jour des courses")
                    }
                    
                    Picker(selection: shoppingMomentBinding) {
                        ForEach(ShoppingMoment.allCases) { moment in
                            Text(moment.label).tag(moment)
                        }
                    } label: {
                        Text("")
                    }
                    .pickerStyle(.radioGroup)
                }
                
                Section(header: Text("Interface")) {
                    ColorPicker(
                        "Couleur principale",
                        selection: Binding(
                            get: { Color(displayP3Hex: appSettings.mainColorHex) },
                            set: { newColor in
                                appSettings.mainColorHex = newColor.displayP3HexString
                            }
                        )
                    )
                    
                    ColorPicker(
                        "Couleur secondaire",
                        selection: Binding(
                            get: { Color(displayP3Hex: appSettings.secondaryColorHex) },
                            set: { newColor in
                                appSettings.secondaryColorHex = newColor.displayP3HexString
                            }
                        )
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
    
    private var planningFirstDayBinding: Binding<Weekday> {
        Binding(
            get: { Weekday(rawValue: planningFirstDayRawValue) ?? .friday },
            set: { newValue in planningFirstDayRawValue = newValue.rawValue }
        )
    }
    
    private var numberOfDaysInPlanningBinding: Binding<DaysInPlanning> {
        Binding(
            get: { DaysInPlanning(rawValue: numberOfDaysInPlanningRawValue) ?? .eightDays },
            set: { newValue in numberOfDaysInPlanningRawValue = newValue.rawValue }
        )
    }
    
    private var shoppingDayBinding: Binding<Weekday> {
        Binding(
            get: { Weekday(rawValue: shoppingDayRawValue) ?? .saturday },
            set: { newValue in shoppingDayRawValue = newValue.rawValue }
        )
    }
    
    private var shoppingMomentBinding: Binding<ShoppingMoment> {
        Binding(
            get: { ShoppingMoment(rawValue: shoppingDayMomentRawValue) ?? .morning },
            set: { newValue in shoppingDayMomentRawValue = newValue.rawValue }
        )
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

enum ShoppingMoment: Int, Identifiable, CaseIterable {
    case morning = 0
    case afternoon = 1
    case evening = 2
    
    var id: Int {
        rawValue
    }
    
    var label: String {
        switch self {
        case .morning:
            return "Matin"
        case .afternoon:
            return "Après-midi"
        case .evening:
            return "Soir"
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppSettings())
}
