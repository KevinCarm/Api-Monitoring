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
    
    @Relationship(deleteRule: .cascade, inverse: \PingRecord.urlModel)
    var history: [PingRecord] = []
    
    init(
        name: String,
        url: String,
        interval: Double,
        lastStatus: Status,
        note: String,
        isRunning: Bool = true
    ) {
        self.name = name
        self.url = url
        self.interval = interval
        self.lastStatus = lastStatus
        self.note = note
        self.isRunning = isRunning
    }
}

enum Status: String, Codable {
    case Up = "Up"
    case Warning = "Warning"
    case Down = "Down"
    case Pause = "Pause"
}
