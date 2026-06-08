//
//  PopoteApp.swift
//  Popote
//
//  Created by Mickael on 29/04/2026.
//

import SwiftUI
import SwiftData

@main
struct PopoteApp: App {

    let sharedModelContainer: ModelContainer

    init() {

        // MARK: - Application Support Directory

        let fileManager = FileManager.default

        guard let applicationSupportURL = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {

            fatalError("Impossible de trouver Application Support")
        }

        // MARK: - Popote Folder

        let appDirectory = applicationSupportURL
            .appendingPathComponent("Popote", isDirectory: true)

        do {
            try fileManager.createDirectory(
                at: appDirectory,
                withIntermediateDirectories: true
            )

            print("APP DIRECTORY OK:")
            print(appDirectory.path)

        } catch {
            fatalError("Impossible de créer le dossier Popote : \(error)")
        }

        // MARK: - Store URL

        let storeURL = appDirectory
            .appendingPathComponent("default.store")

        print("STORE URL:")
        print(storeURL.path)

        // MARK: - Existing Store Info

        let storeExists = fileManager.fileExists(atPath: storeURL.path)

        print("STORE EXISTS:", storeExists)

        if storeExists {

            do {

                let attributes = try fileManager.attributesOfItem(
                    atPath: storeURL.path
                )

                if let size = attributes[.size] as? NSNumber {
                    print("STORE SIZE:", size)
                }

                if let modificationDate = attributes[.modificationDate] as? Date {
                    print("LAST MODIFICATION:", modificationDate)
                }

            } catch {
                print("Impossible de lire les attributs du store:", error)
            }
        }

        // MARK: - SwiftData Schema

        let schema = Schema([

            Guest.self,
            GuestsGroup.self,
            Ingredient.self,
            MealIngredient.self,
            MealItem.self,
            ShoppingList.self,
            ShoppingItem.self,
            PlannedMeal.self
        ])

        // MARK: - Model Configuration

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: storeURL
        )

        // MARK: - Create Container

        do {

            sharedModelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            print("MODEL CONTAINER CREATED")

        } catch {

            print("MODEL CONTAINER ERROR:")
            print(error)

            fatalError("Impossible de créer le ModelContainer")
        }
    }

    var body: some Scene {

        WindowGroup {

            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
