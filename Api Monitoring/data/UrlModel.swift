//
//  UrlModel.swift
//  Api Monitoring
//
//  Created by Kevin Carmona.S on 5/21/26.
//

import Foundation
import SwiftData

@Model class UrlModel {
    var name: String
    @Attribute(.unique) var url: String
    var interval: Double
    var lastStatus: Status
    private var latencyData: Data = Data()
    var note: String
    var isRunning: Bool
    
    @Transient var latency: [Int] {
        get {
            (try? JSONDecoder().decode([Int].self, from: latencyData)) ?? []
        } set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                latencyData = encoded
            }
        }
    }
    
    init(
        name: String,
        url: String,
        interval: Double,
        lastStatus: Status,
        latency: [Int] = [],
        note: String,
        isRunning: Bool = true
    ) {
        self.name = name
        self.url = url
        self.interval = interval
        self.lastStatus = lastStatus
        self.note = note
        self.isRunning = isRunning
        
        if let encoded = try? JSONEncoder().encode(latency) {
            self.latencyData = encoded
        }
    }
}

enum Status: String, Codable {
    case Up = "Up"
    case Warning = "Warning"
    case Down = "Down"
    case Pause = "Pause"
}
