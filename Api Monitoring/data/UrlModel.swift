//
//  UrlModel.swift
//  Api Monitoring
//
//  Created by Kevin Carmona.S on 5/21/26.
//

import Foundation
import SwiftData

@Model class UrlModel: Identifiable {
    var id =  UUID()
    var name: String
    var url: String
    var interval: Double
    var lastStatus: Status
    var latency: Int
    var note: String
    
    init(
        name: String,
        url: String,
        interval: Double,
        lastStatus: Status,
        latency: Int,
        note: String
    ) {
        self.id = UUID()
        self.name = name
        self.url = url
        self.interval = interval
        self.lastStatus = lastStatus
        self.latency = latency
        self.note = note
    }
}

enum Status: String, Codable {
    case Up
    case Warning
    case Down
}
