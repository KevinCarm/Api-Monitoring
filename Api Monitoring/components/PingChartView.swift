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
    
    private var urlModel: UrlModel?
    
    private let colorArea = LinearGradient(
        gradient: Gradient(colors: [
            Color.green.opacity(0.5),
            Color.green.opacity(0.05)
        ]),
        startPoint: .top,
        endPoint: .bottom
        )
    
    init(urlModel: UrlModel?) {
        self.urlModel = urlModel
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
            HStack {
                Image(systemName: "network")
                    .resizable()
                    .scaledToFit()
                    .padding(3)
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.blue)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.blue.opacity(0.2))
                    )
                VStack {
                    Text(urlModel!.name)
                        .font(.title2.bold())
                    HStack {
                        let upImage = Image(systemName: "circle.fill")
                            .foregroundStyle(.green)
                        let warningImage = Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.yellow)
                        let downImage = Image(systemName: "x.circle.fill")
                            .foregroundStyle(.red)
                        let pauseImage = Image(systemName: "pause.fill")
                            .foregroundStyle(.gray)
                        
                        switch(urlModel!.lastStatus) {
                        case .Up:
                            upImage
                        case .Warning:
                            warningImage
                        case .Down:
                            downImage
                        case .Pause:
                            pauseImage
                        }
                        Text(urlModel!.lastStatus.rawValue)
                    }
                    .padding(.horizontal, 10)
                    .frame(height: 25)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                urlModel!.lastStatus == .Up ? .green
                                    .opacity(
                                        0.2
                                    ) : urlModel!.lastStatus == .Warning ? .yellow.opacity(
                                        0.2
                                    )
                                : .red.opacity(0.2)
                                )
                    )
                }.padding()
            }
            Divider()
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
            .chartYScale(domain: 0...(pings.map { $0.latency }.max() ?? 50.0) * 1.2)
            .chartXScale(domain: (pingsOrdered.first?.timestamp ?? Date())...(pingsOrdered.last?.timestamp ?? Date()))
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
    PingChartView(
        urlModel: UrlModel(
            name: "Poke Api",
            url: "",
            interval: 0.0,
            lastStatus: .Up,
            note: ""
        )
    )
}
