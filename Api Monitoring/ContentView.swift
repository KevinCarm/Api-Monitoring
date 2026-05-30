//
//  ContentView.swift
//  Api Monitoring
//
//  Created by Kevin Carmona.S on 5/19/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @State private var isAddButtonClicked: Bool = false
    
    @Query var urls: [UrlModel]
    
    @State public var selectedUrlModel: UrlModel?
    @State public var isShowingChart: Bool = false
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationSplitView( sidebar: {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("PROJECTS")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.leading, 12)
                NavigationViewItem(
                    icon: "display",
                    count: urls.count,
                    title: "All monitors",
                    imageForeground: .gray
                )
                
                Divider()
                
                HStack {
                    Text("STATUS")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.leading, 12)
                NavigationViewItem(
                    icon: "circle",
                    count: urls.filter{ $0.lastStatus == .Up }.count,
                    title: "Up",
                    imageForeground: .green
                )
                NavigationViewItem(
                    icon: "exclamationmark.triangle",
                    count: urls.filter{ $0.lastStatus == .Warning }.count,
                    title: "Warning",
                    imageForeground: .yellow
                )
                NavigationViewItem(
                    icon: "x.circle",
                    count: urls.filter{ $0.lastStatus == .Down }.count,
                    title: "Down",
                    imageForeground: .red
                )
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.top, 16)
            .navigationSplitViewColumnWidth(min: 260, ideal: 260, max: 260)
        }, detail: {
            HStack {
                HStack {
                    TableContentView(selectedUrlModel: $selectedUrlModel, isShowingChart: $isShowingChart)
                        .frame(maxWidth: .infinity)
                    if isShowingChart {
                        PingChartView(urlModel: selectedUrlModel)
                            .frame(width: 550)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button {
                            isAddButtonClicked = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                Text("Add URL")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .popover(isPresented: $isAddButtonClicked, arrowEdge: .bottom) {
                            AddNewUrlView(isPresented: $isAddButtonClicked)
                        }
                    }
                }
                .padding()
                .navigationTitle("")
            }
        })
        .onDisappear {
            for url in urls {
                url.isRunning = false
            }
            try? modelContext.save()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UrlModel.self, configurations: config)
    return ContentView()
        .modelContainer(container)
}
