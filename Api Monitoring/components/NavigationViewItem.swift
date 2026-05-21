//
//  NavigationViewItem.swift
//  Api Monitoring
//
//  Created by Kevin Carmona.S on 5/19/26.
//

import SwiftUI

struct NavigationViewItem: View {
    
    public var icon: String
    @State public var count: Int
    public var title: String
    public var imageForeground: Color
    
    init(icon: String, count: Int, title: String, imageForeground: Color) {
        self.icon = icon
        self.count = count
        self.title = title
        self.imageForeground = imageForeground
    }
    
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: icon)
                    .symbolRenderingMode(.multicolor)
                    .foregroundStyle(imageForeground)
                Text(title)
            }
            Spacer()
            Text("\(count)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 25, height: 25)
                .background(
                    Circle()
                        .fill(Color.gray.opacity(0.6))
                )
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationViewItem(
        icon: "display",
        count: 12,
        title: "All monitors",
        imageForeground: .white
    )
}
