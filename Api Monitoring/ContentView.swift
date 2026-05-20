//
//  ContentView.swift
//  Api Monitoring
//
//  Created by Kevin Carmona.S on 5/19/26.
//

import SwiftUI

struct ContentView: View {
    
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
                    imageForeground: .white
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
        },
 detail: {
            
        })
    }
}

#Preview {
    ContentView()
}
