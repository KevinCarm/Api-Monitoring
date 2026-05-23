//
//  TableContentView.swift
//  Api Monitoring
//
//  Created by Kevin Carmona.S on 5/21/26.
//

import SwiftUI
import SwiftData

struct TableContentView: View {

    @Query var urls: [UrlModel]
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Table(urls) {
            TableColumn("Name") { url in
                HStack(spacing: 10) {
                    Button {
                        print("Clicking")
                    } label: {
                        Image(systemName: "play.fill")
                            .foregroundStyle(.green)
                    }
                    Text(url.name)
                }
            }
            TableColumn("URL", value: \.url)
            TableColumn("Interval") { url in
                Text("\(Int(url.interval))s")
                    .font(.system(size: 12))
                    .foregroundColor(colorScheme == .light ? .black: .white)
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
                    case .Up:
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
                            url.lastStatus == .Up ? .green
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
                let averageLatency = url.latency.reduce(0, +) / (url.latency.count == 0 ? 1 : url.latency.count)
                let latency = averageLatency > 1000 ?
                        Double(averageLatency) / 1000.0 : Double(averageLatency)
                
                HStack(spacing: 10) {
                    Text("\(latency.formatted(.number.precision(.fractionLength(0...1)))) \(averageLatency >= 1000 ? "s" : "ms")")
                        .foregroundStyle(.green)
                        .padding(.horizontal, 10)
                        .frame(height: 25)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.green.opacity(0.2))
                        )
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: UrlModel.self, configurations: config)
    let url = UrlModel(name: "Pokemon Api", url: "https://pokeapi.co/api/v2/pokemon/ditto", interval: 1.0, lastStatus: .Up, latency: [123, 100, 130], note: "")
    container.mainContext.insert(url)
    return TableContentView().modelContainer(container)
}
