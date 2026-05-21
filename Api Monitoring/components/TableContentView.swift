//
//  TableContentView.swift
//  Api Monitoring
//
//  Created by Kevin Carmona.S on 5/21/26.
//

import SwiftUI

struct TableContentView: View {
    
    @State var urls: [UrlModel]
    
    var body: some View {
        Table(urls) {
            TableColumn("Name", value: \.name)
            TableColumn("URL") { url in
                Text(url.url)
                    .foregroundStyle(.gray.opacity(0.9))
            }
            TableColumn("Interval") { url in
                Text("\(url.interval)m")
                    .font(.caption)
                    .foregroundColor(.black)
                    .frame(width: 35, height: 25)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.2))
                    )
            }
            TableColumn("Last Status") { url in
                HStack {
                    let upImage = Image(systemName: "circle.fill")
                        .foregroundStyle(.green)
                    let warningImage = Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.yellow)
                    let downImage = Image(systemName: "x.circle.fill")
                        .foregroundStyle(.red)
                    
                    switch(url.lastStatus) {
                    case .UP:
                        upImage
                    case .Warning:
                        warningImage
                    case .Down:
                        downImage
                    }
                    Text(url.lastStatus.rawValue)
                }
                .padding(.horizontal, 10)
                .frame(height: 25)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            url.lastStatus == .UP ? .green
                                .opacity(
                                    0.2
                                ) : url.lastStatus == .Warning ? .yellow.opacity(
                                    0.2
                                )
                            : .red.opacity(0.2)
)
                )
            }
            TableColumn("Latency") { url in
                var latency = url.latency > 1000 ?
                        Double(url.latency) / 1000.0 : Double(url.latency)
                Text("\(latency.formatted(.number.precision(.fractionLength(0...1)))) \(url.latency >= 1000 ? "min" : "ms")")
            }
        }
    }
}

#Preview {
    TableContentView(
        urls: [
            UrlModel(
                name: "Api Gateway",
                url: "https://api.acme.com",
                interval: 1,
                lastStatus: .UP,
                latency: 120
            ),
            UrlModel(
                name: "Report Service",
                url: "https://report.acme.com",
                interval: 2,
                lastStatus: .Down,
                latency: 1210
            ),
            UrlModel(
                name: "Search Service",
                url: "https://search.acme.com",
                interval: 4,
                lastStatus: .Warning,
                latency: 140
            )
        ]
    )
}
