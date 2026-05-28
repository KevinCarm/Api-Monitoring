
import SwiftData
import Foundation

@Model class PingRecord {
    var id: UUID
    var timestamp: Date
    var latency: Double
    var statusCode: Int
    var errorMessage: String?
    
    var urlModel: UrlModel?
    
    var isSuccess: Bool {
        return statusCode >= 200 && statusCode < 300
    }

    init(
        id: UUID = UUID(),
        timestamp: Date = .now,
        latency: Double,
        statusCode: Int,
        errorMessage: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.latency = latency
        self.statusCode = statusCode
        self.errorMessage = errorMessage
    }
}
