//
//  RoutinesPanel.swift
//  to do app
//
//  Created by Macbook Air on 19.10.2025.
//
import SwiftUI

struct RoutinesPanel: View {
    @ObservedObject var viewModel: TodoViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var newRoutineTitle = ""
    @State private var isResetting = false
    @State private var isWaitingForConfirmation = false
    @State private var showConfetti = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("⚡")
                        .font(.system(size: 32))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Günlük Rutinler")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Her gün tekrar eden alışkanlıklar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Yeni Gün Butonu
                    Button(action: {
                        if !isWaitingForConfirmation {
                            // 1. Aşama: "Onayla" durumuna geç
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isWaitingForConfirmation = true
                            }
                        } else {
                            // 2. Aşama: Gerçekten sıfırla
                            viewModel.resetAllRoutines()
                            
                            // Animasyon göster
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isResetting = true
                            }
                            
                            // 1 saniye sonra normale dön
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isResetting = false
                                    isWaitingForConfirmation = false
                                }
                            }
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: isResetting ? "checkmark.circle.fill" : (isWaitingForConfirmation ? "checkmark.circle" : "sunrise.fill"))
                                .font(.system(size: 14, weight: .medium))
                            
                            Text(isResetting ? "Tamamlandı!" : (isWaitingForConfirmation ? "Onayla" : "Yeni Gün"))
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isResetting ? Color.green : (isWaitingForConfirmation ? Color.orange : Color.blue))
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.routines.isEmpty)
                }
                .padding()
            }
            .background(Color.adaptiveWindowBackground)
            
            Divider()
            
            // Add Input (Fixed)
            HStack {
                TextField("Yeni rutin ekle...", text: $newRoutineTitle)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: addRoutine) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .disabled(newRoutineTitle.isEmpty)
            }
            .padding()
            .background(Color.adaptiveWindowBackground)
            
            // Routines List veya Empty State (Scrollable)
            if viewModel.routines.isEmpty {
                // Empty State
                EmptyRoutinesView()
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .frame(maxHeight: .infinity)
            } else {
                // Routines List with Drag & Drop
                List {
                    ForEach(viewModel.routines) { routine in
                        RoutineCard(routineId: routine.id, viewModel: viewModel)
                            .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                            .listRowSeparator(.hidden)
                    }
                    .onMove(perform: viewModel.moveRoutine)
                    
                    // Stats Card
                    StatsCard(viewModel: viewModel)
                        .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
        .background(Color.adaptiveWindowBackground)
        .overlay(
            // Confetti overlay - StatsCard'dan başlayacak şekilde
            Group {
                if showConfetti {
                    VStack {
                        Spacer()
                        ConfettiView()
                            .allowsHitTesting(false)
                            .frame(height: 200)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                    showConfetti = false
                                }
                            }
                    }
                }
            }
        )
        .onReceive(NotificationCenter.default.publisher(for: .showConfetti)) { _ in
            showConfetti = true
        }
    }
    
    private func addRoutine() {
        guard !newRoutineTitle.isEmpty else { return }
        viewModel.addRoutine(title: newRoutineTitle)
        newRoutineTitle = ""
    }
}

struct RoutineCard: View {
    let routineId: UUID
    @ObservedObject var viewModel: TodoViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingDeleteAlert = false
    
    // Real-time routine data
    private var routine: Routine {
        viewModel.routines.first(where: { $0.id == routineId }) ?? Routine(title: "Bulunamadı")
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: { viewModel.toggleRoutine(routine) }) {
                Image(systemName: routine.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(routine.isCompleted ? .blue : .gray)
            }
            .buttonStyle(.plain)
            
            // Title
            Text(routine.title)
                .font(.body)
                .strikethrough(routine.isCompleted)
                .foregroundColor(routine.isCompleted ? .secondary : .primary)
            
            Spacer()
            
            // Delete Button
            Button(action: { showingDeleteAlert = true }) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.adaptiveCardBackground)
                .shadow(
                    color: themeManager.isLightMode ? Color.black.opacity(0.1) : Color.clear,
                    radius: themeManager.isLightMode ? 4 : 0,
                    x: 0,
                    y: themeManager.isLightMode ? 2 : 0
                )
        )
        .confirmationDialog(
            "Bu rutini silmek istediğinizden emin misiniz?",
            isPresented: $showingDeleteAlert,
            titleVisibility: .visible
        ) {
            Button("Sil", role: .destructive) {
                viewModel.deleteRoutine(routine)
            }
            Button("İptal", role: .cancel) {}
        } message: {
            Text("\(routine.title) kalıcı olarak silinecek.")
        }
    }
}

struct EmptyRoutinesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 50))
                .foregroundColor(.blue.opacity(0.4))
            
            VStack(spacing: 6) {
                Text("Henüz Rutin Yok")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Yukarıdaki alana yazarak günlük rutinlerinizi ekleyin")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct StatsCard: View {
    @ObservedObject var viewModel: TodoViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            Text("📊 Bugünün İstatistiği")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text("Tamamlanan:")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(viewModel.completedRoutinesCount) / \(viewModel.routines.count)")
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * viewModel.completionPercentage, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.adaptiveCardBackground)
                .shadow(
                    color: themeManager.isLightMode ? Color.black.opacity(0.1) : Color.clear,
                    radius: themeManager.isLightMode ? 4 : 0,
                    x: 0,
                    y: themeManager.isLightMode ? 2 : 0
                )
        )
    }
}
