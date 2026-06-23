//
//  WelcomeView.swift
//  Popote
//
//  Created by Mickael on 23/06/2026.
//

import SwiftUI

struct WelcomeView: View {
    
    @Environment(AppSettings.self) private var appSettings
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 24) {
            
            Spacer()
            
            Image("chef_welcome")
                .resizable()
                .frame(width: 500, height: 500)
            
            Text("Bienvenue dans Popote")
                .font(.system(.largeTitle, design: .rounded))
                .foregroundStyle(appSettings.mainColorContrast)
                .fontWeight(.bold)
            
            Text("Avant de commencer, tu peux choisir quelques préférences pour adapter le planning à ton usage.")
                .font(.title3)
                .foregroundStyle(appSettings.mainColor)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 460)
            
            Button("Suivant") {
                showSettings = true
            }
            .controlSize(.extraLarge)
            //.tint(appSettings.mainColor)
            .keyboardShortcut(.defaultAction)
            
            Spacer()
            
            HStack {
                Button("Ignorer") {
                    hasSeenOnboarding = true
                }
                
                Spacer()
                
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 32)
        }
        .background(
            Gradient(colors: [
                appSettings.mainColor.opacity(0.2),
                appSettings.mainColor.opacity(0.4)
            ])
        )
        .frame(minWidth: 600, minHeight: 420)
        .sheet(isPresented: $showSettings, onDismiss: {
            hasSeenOnboarding = true
        }) {
            SettingsView()
                .frame(minWidth: 500, minHeight: 400)
        }
    }
}

#Preview {
    WelcomeView()
}
