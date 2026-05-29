//
//  PingChartView.swift
//  Api Monitoring
//
//  Created by Kevin Carmona Serrano on 28/05/26.
//

import SwiftUI
import SwiftData
import Charts

struct PingChartView: View {
    
    
    @Query private var pings: [PingRecord]
    
    @State private var animating: Bool = false
    
    private let colorArea = LinearGradient(
        gradient: Gradient(colors: [
            Color.green.opacity(0.5),
            Color.green.opacity(0.05)
        ]),
        startPoint: .top,
        endPoint: .bottom
        )
    
    init(urlModel: UrlModel?) {
        let urlId = urlModel?.persistentModelID
        var descriptor = FetchDescriptor<PingRecord>(
            predicate: #Predicate { $0.urlModel?.persistentModelID == urlId },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = 100
        
        _pings = Query(descriptor)
    }
    
    var body: some View {
        let pingsOrdered = pings.reversed()
        
        VStack(alignment: .leading) {
            Text("Latency (ms)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            Chart(pingsOrdered) { record in
                let currentLatency = animating ? record.latency : 0.0
                AreaMark(
                    x: .value("Time", record.timestamp),
                    y: .value("Latency", currentLatency)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(colorArea)
                
                LineMark(
                    x: .value("Time", record.timestamp),
                    y: .value("Latency", currentLatency)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(.green)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(.gray.opacity(0.2))
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(.gray.opacity(0.2))
                    AxisValueLabel(format: .dateTime.hour().minute())
                }
            }
            .chartXAxisLabel(position: .bottom, alignment: .center) {
                Text("Time").font(.caption).foregroundColor(.secondary)
            }
            .chartYScale(domain: 0...(pings.map { $0.latency }.max() ?? 50.0) * 0.5)
            .frame(height: 180)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    animating = true
                }
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    PingChartView(urlModel: UrlModel(name: "", url: "", interval: 0.0, lastStatus: .Down, note: ""))
}
