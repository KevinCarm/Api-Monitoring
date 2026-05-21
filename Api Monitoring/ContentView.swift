//
//  ContentView.swift
//  Api Monitoring
//
//  Created by Kevin Carmona.S on 5/19/26.
//

import SwiftUI

struct ContentView: View {
    
    let urls =  [
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
    
    @State private var isAddButtonClicked: Bool = false
    
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
                    count: 15,
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
                    count: 3,
                    title: "Up",
                    imageForeground: .green
                )
                NavigationViewItem(
                    icon: "exclamationmark.triangle",
                    count: 10,
                    title: "Warning",
                    imageForeground: .yellow
                )
                NavigationViewItem(
                    icon: "x.circle",
                    count: 2,
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
                VStack {
                    TableContentView(urls: urls)
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
    }
}

#Preview {
    ContentView()
        .frame(minWidth: 800, minHeight: 500)
}
