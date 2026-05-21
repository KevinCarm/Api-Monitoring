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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: UrlModel.self)
    }
}
