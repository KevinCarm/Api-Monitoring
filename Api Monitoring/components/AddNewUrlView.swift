//
//  AddNewUrlView.swift
//  Api Monitoring
//
//  Created by Kevin Carmona.S on 5/21/26.
//

import SwiftUI
import SwiftData

struct AddNewUrlView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var name: String = ""
    @State private var urlString: String = ""
    @State private var interval: Double = 1.0
    @State private var description: String = ""
    
    @State private var apiCallUtil: ApiCallUtil?
    
    
    @Binding var isPresented: Bool
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add new Endpoint")
                .font(.headline)
            
            Form {
                TextField("Service Name:", text: $name)
                TextField("URL:", text: $urlString)
                TextField("Description:", text: $description, axis: .vertical)
                    .lineLimit(2...4)
        
                HStack {
                    Text("Interval")
                    Slider(value: $interval, in: 0...300, step: 1)
                        .tint(.purple)
                        .controlSize(.small)
                        .cornerRadius(4)
                    
                    let intervalValue = "\(interval.formatted(.number.precision(.fractionLength(0...1)))) seg"
                    
                    Text(intervalValue)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .frame(width: 50)
                }
                .padding()
            }
            Spacer()
            HStack {
                Spacer()

                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.plain)

                Button("Save") {
                    let model = UrlModel(
                        name: name,
                        url: urlString,
                        interval: interval,
                        lastStatus: .Up,
                        latency: [],
                        note: description
                    )
                    modelContext.insert(model)
                    try? modelContext.save()
                    
                    Task {
                        await apiCallUtil?.startMonitoringApi(
                                for: urlString,
                                each: interval,
                                method: "GET"
                            )
                    }
                    
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear {
            let container = modelContext.container
            let apiCallUtil = ApiCallUtil(modelContainer: container)
            self.apiCallUtil = apiCallUtil
        }
        .padding()
        .frame(width: 600, height: 280)
        }
}

#Preview {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: UrlModel.self, configurations: config)
        return AddNewUrlView(isPresented: .constant(true))
            .modelContainer(container)
}
