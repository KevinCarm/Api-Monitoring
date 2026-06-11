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
    
    func startMonitoringApi(for urlString: String, each seconds: Double, method: String) async {
        let cleanKey = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        print(cleanKey)
        if let existTask = activeTasks[cleanKey] {
            existTask.cancel()
        }
        await stopMonitoring(for: cleanKey)
        await Task.yield()
        
        let newTask = Task { [cleanKey] in
            guard let url = URL(string: cleanKey) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = method
            
            while !Task.isCancelled {
                if Task.isCancelled { break }
                do {
                    let startTime = Date()
                    let (_, response) = try await URLSession.shared.data(for: request)
                    let endTime = Date()
                    let status = (response as? HTTPURLResponse)?.statusCode ?? 0
                    let latencySeg = endTime.timeIntervalSince(startTime)
                    let latencyMill = latencySeg * 1000
                    print(urlString)
                    print("\(latencyMill)ms")
                    if Task.isCancelled { break }
                    await updateUrlData(
                        url: cleanKey,
                        status: status,
                        latency: Int(latencyMill)
                    )
                    try await Task.sleep(for: .seconds(seconds))
                } catch {
                    if error is CancellationError || Task.isCancelled {
                        break
                    }
                    if !Task.isCancelled {
                        try? await Task.sleep(for: .seconds(seconds))
                    }
                }
            }
        }
        activeTasks[cleanKey] = newTask
    }
    
    private func updateUrlData(url: String, status: Int, latency: Int) async {
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
                
                let newPing = PingRecord(
                    latency: Double(latency), statusCode: status
                )
                newPing.urlModel = existData
                context.insert(newPing)
                
                existData.lastStatus = statusEnum!
                
                let idURL = existData.persistentModelID
                var descriptor = FetchDescriptor<PingRecord>(
                    predicate: #Predicate { $0.urlModel?.persistentModelID == idURL }
                )
                if let total = try? context.fetchCount(descriptor), total > 5000 {
                    descriptor.sortBy = [
                        SortDescriptor(\PingRecord.timestamp, order: .forward)
                    ]
                    descriptor.fetchLimit = total - 5000

                    if let exced = try? context.fetch(descriptor) {
                        for oldPing in exced {
                            context.delete(oldPing)
                        }
                    }
                }
                try? context.save()
            }
        } catch {
            
        }
    }
    
    
    func stopMonitoring(for url: String) async {
        let cleanKey = url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let task = activeTasks.removeValue(forKey: cleanKey) else {
            return
        }
        print("Stopping...")
        task.cancel()
        _ = await task.result
    }
    
    func deleteTask(for url: String) async {
        print(url)
        activeTasks[url]?.cancel()
        activeTasks.removeValue(forKey: url)
        
        let context = modelContext
        let targetUrl = url
        
        let descriptor = FetchDescriptor<UrlModel>(
            predicate: #Predicate { $0.url == targetUrl }
        )
        
        if let exists = try? context.fetch(descriptor).first {
            context.delete(exists)
            try? context.save()
        }
    }
    
    func stopAllTasks() async {
        for task in activeTasks.values {
            if !task.isCancelled {
                task.cancel()
            }
        }
        activeTasks.removeAll()
    }
}
