//
//  UrlModel.swift
//  Api Monitoring
//
//  Created by Kevin Carmona.S on 5/21/26.
//

import Foundation

struct UrlModel: Identifiable {
    var id: UUID
    var name: String
    var url: String
    var interval: Int
    var lastStatus: Status
    var latency: Int
    
    init(
        name: String,
        url: String,
        interval: Int,
        lastStatus: Status,
        latency: Int
    ) {
        self.id = UUID()
        self.name = name
        self.url = url
        self.interval = interval
        self.lastStatus = lastStatus
        self.latency = latency
    }
}

enum Status: String {
    case UP = "Up"
    case Warning = "Warning"
    case Down = "Down"
}
