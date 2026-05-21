//
//  AddNewUrlView.swift
//  Api Monitoring
//
//  Created by Kevin Carmona.S on 5/21/26.
//

import SwiftUI

struct AddNewUrlView: View {
    
    @State private var name: String = ""
    @State private var urlString: String = ""
    @State private var interval: Double = 0.5
    @State private var description: String = ""
    
    @Binding var isPresented: Bool
    
    public init(isPresented: Binding<Bool>) {
            self._isPresented = isPresented
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Añadir Nuevo Endpoint")
                .font(.headline)
            
            Form {
                TextField("Nombre del servicio:", text: $name)
                TextField("URL de la API:", text: $urlString)
                TextField("Descripción:", text: $description, axis: .vertical)
                    .lineLimit(2...4)
        
                HStack {
                    Text("Interval")
                    Slider(value: $interval, in: 1...300, step: 1)
                    Text(
                        "\(interval.formatted(.number.precision(.fractionLength(0...1)))) seg"
                    )
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .frame(width: 50)
                }
                .padding()
            }
            Spacer()
            HStack {
                Spacer()

                Button("Cancelar") {
                    isPresented = false
                }
                .buttonStyle(.plain)

                Button("Guardar") {
                    print("Guardando: \(name) - \(urlString)")
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 600, height: 280)
        }
}

#Preview {
    AddNewUrlView(isPresented: .constant(false))
}
