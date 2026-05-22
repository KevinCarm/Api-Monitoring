//
//  ApiCallUtil.swift
//  Api Monitoring
//
//  Created by Kevin Carmona.S on 5/22/26.
//

import Foundation

class ApiCallUtil {
    private var activeTasks: [String: Task<Void, Never>] = [:]
    
    func startMonitoringApi(for urlString: String, each seconds: Double, method: String) {
        stopMonitoring(for: urlString)
        
        let newTask = Task {
            guard let url = URL(string: urlString) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = method
            
            while !Task.isCancelled {
                do {
                    let startTime = Date()
                    let (_, response) = try await URLSession.shared.data(for: request)
                    let endTime = Date()
                    let status = (response as? HTTPURLResponse)?.statusCode ?? 0
                    print("🔢 API [\(urlString)] -> Status: \(status)")
                    let latencySeg = endTime.timeIntervalSince(startTime)
                    let latencyMill = latencySeg * 1000
                    print("\(Int(latencyMill))ms")
                    
                    try await Task.sleep(for: .seconds(seconds))
                } catch {
                    break
                }
            }
        }
        activeTasks[urlString] = newTask
    }
    
    func stopMonitoring(for url: String) {
        activeTasks[url]?.cancel()
        activeTasks.removeValue(forKey: url)
    }
}
