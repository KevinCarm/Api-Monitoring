//
//  Api_MonitoringApp.swift
//  Api Monitoring
//
//  Created by Kevin Carmona.S on 5/19/26.
//

import SwiftUI
import SwiftData

@main
struct Api_MonitoringApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: UrlModel.self)
        } catch {
            fatalError("No se pudo inicializar el contenedor")
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
        .commands {
            CommandGroup(after: .newItem) {
                Button("Clean all data...") {
                    deleteAllData()
                }
            }
        }
    }
    
    @MainActor
    private func deleteAllData() {
        let context = container.mainContext

        do {
            try context.delete(model: UrlModel.self)
            try context.save()
            print("Datos eliminados correctamente desde el menú principal.")

            NotificationCenter.default.post(
                name: NSNotification.Name("SwiftDataDidUpdate"),
                object: nil
            )

        } catch {
            print("Error al borrar datos: \(error.localizedDescription)")
        }
    }
}
