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
                VStack {
                    Spacer()
                            .frame(height: 5)
                    HStack(alignment: .center) {
                        Button(action: {
                            isAddButtonClicked = true
                        }, label: {
                            Image(systemName: "plus")
                            Text("Add")
                        })
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .popover(isPresented: $isAddButtonClicked) {
                        AddNewUrlView(isPresented: $isAddButtonClicked)
                    }
                    HStack {
                        TableContentView(urls: urls)
                    }
            }
        })
    }
}

#Preview {
    ContentView()
        .frame(minWidth: 800, minHeight: 500)
}
