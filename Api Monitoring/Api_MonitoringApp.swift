//
//  Api_MonitoringApp.swift
//  Api Monitoring
//
//  Created by Kevin Carmona.S on 5/19/26.
//

import SwiftUI
import SwiftData

@MainActor class GlobalApiManager {
    static let shared = GlobalApiManager()
    var util: ApiCallUtil?
}

@main
struct Api_MonitoringApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: UrlModel.self)
            GlobalApiManager.shared.util = ApiCallUtil(
                modelContainer: container
            )
        } catch {
            
            let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            if let appSupportURL = urls.first {
                let databaseURL = appSupportURL.appendingPathComponent("default.store")
                let shmURL = appSupportURL.appendingPathComponent("default.store-shm")
                let walURL = appSupportURL.appendingPathComponent("default.store-wal")
                
                try? FileManager.default.removeItem(at: databaseURL)
                try? FileManager.default.removeItem(at: shmURL)
                try? FileManager.default.removeItem(at: walURL)
            }
            
            do {
                container = try ModelContainer(for: UrlModel.self)
            } catch {
                fatalError("Error crítico e irrecuperable: \(error.localizedDescription)")
            }
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
