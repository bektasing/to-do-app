//
//  TodoViewModel.swift
//  to do app
//
//  Created by Macbook Air on 19.10.2025.
//
import Foundation
import SwiftUI
import Combine

class TodoViewModel: ObservableObject {
    @Published var projects: [Project] = [] {
        didSet {
            saveData()
        }
    }
    
    @Published var routines: [Routine] = [] {
        didSet {
            saveData()
        }
    }
    
    // UserDefaults anahtarları
    private let projectsKey = "SavedProjects"
    private let routinesKey = "SavedRoutines"
    
    init() {
        loadData()
    }
    
    // MARK: - Project Methods
    func addProject(title: String, description: String, priority: Priority, deadline: Date?, duration: String, icon: String = "📋") {
        let newProject = Project(
            title: title,
            description: description,
            priority: priority,
            deadline: deadline,
            duration: duration,
            icon: icon
        )
        projects.append(newProject)
        SoundManager.shared.playTaskAddSound()
    }
    
    func updateProject(_ project: Project, title: String, description: String, priority: Priority, deadline: Date?, duration: String, icon: String) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].title = title
            projects[index].description = description
            projects[index].priority = priority
            projects[index].deadline = deadline
            projects[index].duration = duration
            projects[index].icon = icon
            SoundManager.shared.playTaskAddSound()
        }
    }
    
    func toggleProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].isCompleted.toggle()
            SoundManager.shared.playTaskCompleteSound()
        }
    }
    
    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
        SoundManager.shared.playTaskDeleteSound()
    }
    
    // MARK: - Routine Methods
    func addRoutine(title: String) {
        let newRoutine = Routine(title: title)
        routines.append(newRoutine)
        SoundManager.shared.playTaskAddSound()
    }
    
    func toggleRoutine(_ routine: Routine) {
        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            routines[index].isCompleted.toggle()
            SoundManager.shared.playTaskCompleteSound()
            
            // Tüm rutinler tamamlandıysa özel ses! 🎉
            if routines.count > 0 && completedRoutinesCount == routines.count {
                SoundManager.shared.playSuccessSound()
            }
        }
    }
    
    func deleteRoutine(_ routine: Routine) {
        routines.removeAll { $0.id == routine.id }
        SoundManager.shared.playTaskDeleteSound()
    }
    
    var completedRoutinesCount: Int {
        routines.filter { $0.isCompleted }.count
    }
    
    var completionPercentage: Double {
        guard !routines.isEmpty else { return 0 }
        return Double(completedRoutinesCount) / Double(routines.count)
    }
    
    // MARK: - Persistence (Kalıcı Depolama)
    
    /// Verileri UserDefaults'a kaydet
    private func saveData() {
        // Projects'i JSON'a çevir ve kaydet
        if let projectsData = try? JSONEncoder().encode(projects) {
            UserDefaults.standard.set(projectsData, forKey: projectsKey)
        }
        
        // Routines'i JSON'a çevir ve kaydet
        if let routinesData = try? JSONEncoder().encode(routines) {
            UserDefaults.standard.set(routinesData, forKey: routinesKey)
        }
    }
    
    /// Verileri UserDefaults'tan yükle
    private func loadData() {
        // Projects'i yükle
        if let projectsData = UserDefaults.standard.data(forKey: projectsKey),
           let decodedProjects = try? JSONDecoder().decode([Project].self, from: projectsData) {
            projects = decodedProjects
        }
        
        // Routines'i yükle
        if let routinesData = UserDefaults.standard.data(forKey: routinesKey),
           let decodedRoutines = try? JSONDecoder().decode([Routine].self, from: routinesData) {
            routines = decodedRoutines
        }
    }
    
    // MARK: - Debug Helper (Geliştirme için)
    
    /// Örnek veri yükle (sadece geliştirme/test için)
    func loadSampleData() {
        projects = [
            Project(
                title: "Website Yenileme Projesi",
                description: "Tasarım, geliştirme ve içerik güncellemeleri",
                priority: .high,
                deadline: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
                duration: "2 hafta",
                icon: "💻"
            ),
            Project(
                title: "Müşteri Sunumu Hazırla",
                description: "Yeni ürün stratejisi sunumu için slaytlar hazırla",
                priority: .medium,
                deadline: Calendar.current.date(byAdding: .day, value: 12, to: Date()),
                duration: "2 gün",
                icon: "📊"
            )
        ]
        
        routines = [
            Routine(title: "Sabah egzersizi (30 dk)"),
            Routine(title: "Email kontrol et"),
            Routine(title: "Günlük planlama yap"),
            Routine(title: "Kitap oku (30 dk)")
        ]
    }
    
    /// Tüm verileri temizle (Debug için)
    func clearAllData() {
        projects = []
        routines = []
    }
}
