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
    @Environment(\.modelContext) private var modelContext

    @State private var selectedUrlId: PersistentIdentifier?
    
    @Binding var selectedUrlModel: UrlModel?
    @Binding var isShowingChart: Bool
    
    private var apiCallUtil: ApiCallUtil {
        guard let util = GlobalApiManager.shared.util else {
            fatalError("El ApiCallUtil global no fue inicializado en App.swift")
        }
        return util
    }
    
    private var selectedUrl: UrlModel? {
        urls.first(where: { $0.id == selectedUrlId })
    }
    
    var body: some View {
        Table(urls, selection: $selectedUrlId) {
            TableColumn("Name") { url in
                HStack(spacing: 10) {
                    Button {
                        Task {
                            await updateIsRunning(url: url.url)
                        }
                    } label: {
                        Image(systemName: url.isRunning ? "pause.fill" : "play.fill")
                            .foregroundStyle(.green)
                    }
                    .buttonStyle(.plain)
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
                    let pauseImage = Image(systemName: "pause.fill")
                        .foregroundStyle(.gray)
                    
                    switch(url.lastStatus) {
                    case .Up:
                        upImage
                    case .Warning:
                        warningImage
                    case .Down:
                        downImage
                    case .Pause:
                        pauseImage
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
                let count = url.history.count
                let latencySum: Double = url.history.reduce(0.0) {(adding, val) -> Double in
                    return adding + val.latency
                }
                let averageLatency = Int(latencySum) / (count == 0 ? 1 : count)
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
                        Task {
                            await apiCallUtil.deleteTask(for: url.url)
                            print("Deleted")
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .onChange(of: selectedUrlId) {_, newID in
            if let newID = newID,
                let model = urls.first(where: { $0.id == newID }) {
                print("Hiciste clic en la URL: \(model.url)")
                withAnimation(.easeOut) {
                    selectedUrlModel = model
                    isShowingChart.toggle()
                }
            }
        }
    }
    
    @MainActor private func updateIsRunning(url: String) async {
        let cleanedUr = url.trimmingCharacters(in: .whitespacesAndNewlines)

        let context = modelContext
        let descriptor = FetchDescriptor<UrlModel>(
            predicate: #Predicate {
                $0.url == cleanedUr
            }
        )
        guard let exists = try? context.fetch(descriptor).first else {
            return
        }

        let util = apiCallUtil
        if exists.isRunning {
            await util.stopMonitoring(for: cleanedUr)
            exists.isRunning = false
        } else {
            exists.isRunning = true

            await util.startMonitoringApi(
                for: cleanedUr,
                each: exists.interval,
                method: "GET"
            )
        }
        try? context.save()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: UrlModel.self, configurations: config)
    let url = UrlModel(name: "Pokemon Api", url: "https://pokeapi.co/api/v2/pokemon/ditto", interval: 1.0, lastStatus: .Up, note: "")
    container.mainContext.insert(url)
    return TableContentView(selectedUrlModel: .constant(url), isShowingChart: .constant(false)).modelContainer(container)
}
