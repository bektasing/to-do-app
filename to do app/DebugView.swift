//
//  DebugView.swift
//  to do app
//
//  Created by Macbook Air on 21.10.2025.
//

import SwiftUI

struct DebugView: View {
    @ObservedObject var viewModel: TodoViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🔍 Debug Bilgileri")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Kapat")
            }
            
            Divider()
            
            // Rutin Sayısı
            HStack {
                Text("Toplam Rutin:")
                    .fontWeight(.semibold)
                Spacer()
                Text("\(viewModel.routines.count)")
                    .foregroundColor(.blue)
            }
            
            HStack {
                Text("Tamamlanan:")
                    .fontWeight(.semibold)
                Spacer()
                Text("\(viewModel.routines.filter { $0.isCompleted }.count)")
                    .foregroundColor(.green)
            }
            
            Divider()
            
            // UserDefaults Kontrolü
            VStack(alignment: .leading, spacing: 8) {
                Text("UserDefaults Durumu:")
                    .fontWeight(.semibold)
                
                // Standard UserDefaults
                if let data = UserDefaults.standard.data(forKey: "SavedRoutines") {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Standard: \(data.count) bytes")
                    }
                } else {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("Standard: Veri yok")
                    }
                }
            }
            
            Divider()
            
            // Manuel Kaydet Butonu
            Button(action: {
                saveManually()
            }) {
                HStack {
                    Image(systemName: "arrow.down.doc.fill")
                    Text("Manuel Kaydet")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 400, height: 500)
    }
    
    private func saveManually() {
        // Manuel kaydet
        if let routinesData = try? JSONEncoder().encode(viewModel.routines) {
            UserDefaults.standard.set(routinesData, forKey: "SavedRoutines")
            UserDefaults.standard.synchronize()
            
            print("✅ Manuel kayıt başarılı: \(viewModel.routines.count) rutin")
        }
    }
}
