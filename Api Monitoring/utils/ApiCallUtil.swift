//
//  ApiCallUtil.swift
//  Api Monitoring
//
//  Created by Kevin Carmona.S on 5/22/26.
//

import Foundation
import SwiftData

@ModelActor actor ApiCallUtil {
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
                    let latencySeg = endTime.timeIntervalSince(startTime)
                    let latencyMill = latencySeg * 1000
                    
                    self.updateUrlData(url: urlString, status: status, latency: Int(latencyMill))
                    try await Task.sleep(for: .seconds(seconds))
                } catch {
                    break
                }
            }
        }
        activeTasks[urlString] = newTask
    }
    
    private func updateUrlData(url: String, status: Int, latency: Int) {
        let context = modelContext
        
        let descriptor = FetchDescriptor<UrlModel>(
            predicate: #Predicate { $0.url == url }
        )
        
        do {
            if let existData = try context.fetch(descriptor).first {
                var statusEnum: Status? = .Down
                if [200, 201, 204].contains(status) {
                    statusEnum = .Up
                } else if [203, 299, 429].contains(status) || latency > 500 {
                    statusEnum = .Warning
                }
                existData.lastStatus = statusEnum!
                var historial = existData.latency
                historial.append(latency)
                if historial.count > 30 {
                    historial.removeFirst()
                }
                existData.latency = historial
                
                if context.hasChanges {
                    try context.save()
                }
            }
        } catch {
            
        }
    }
    
    
    private func stopMonitoring(for url: String) {
        activeTasks[url]?.cancel()
        activeTasks.removeValue(forKey: url)
    }
    
    func stopAllTasks() {
        for task in activeTasks.values {
            if !task.isCancelled {
                task.cancel()
            }
        }
        activeTasks.removeAll()
    }
}
