//
//  DataManager.swift
//  to do app
//
//  Created by Macbook Air on 19.10.2025.
//

import Foundation

// Şablon sistemi kaldırıldı - ProjectTemplate artık yok

class DataManager {
    static let shared = DataManager()
    
    private let documentsDirectory: URL
    private let projectsFile: URL
    private let routinesFile: URL
    
    private init() {
        // Documents dizinini al
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Dosya yollarını oluştur
        projectsFile = documentsDirectory.appendingPathComponent("projects.json")
        routinesFile = documentsDirectory.appendingPathComponent("routines.json")
        
        print("📁 DataManager initialized")
        print("📁 Documents directory: \(documentsDirectory.path)")
        print("📁 Projects file: \(projectsFile.path)")
        print("📁 Routines file: \(routinesFile.path)")
    }
    
    // MARK: - Projects
    
    func saveProjects(_ projects: [Project]) {
        do {
            let data = try JSONEncoder().encode(projects)
            try data.write(to: projectsFile)
            print("💾 Projects saved to file: \(projects.count) items")
        } catch {
            print("❌ Failed to save projects: \(error)")
        }
    }
    
    func loadProjects() -> [Project] {
        do {
            let data = try Data(contentsOf: projectsFile)
            let projects = try JSONDecoder().decode([Project].self, from: data)
            print("📂 Projects loaded from file: \(projects.count) items")
            return projects
        } catch {
            print("📂 No projects file found or failed to load: \(error)")
            return []
        }
    }
    
    // MARK: - Routines
    
    func saveRoutines(_ routines: [Routine]) {
        do {
            let data = try JSONEncoder().encode(routines)
            try data.write(to: routinesFile)
            print("💾 Routines saved to file: \(routines.count) items")
        } catch {
            print("❌ Failed to save routines: \(error)")
        }
    }
    
    func loadRoutines() -> [Routine] {
        do {
            let data = try Data(contentsOf: routinesFile)
            let routines = try JSONDecoder().decode([Routine].self, from: data)
            print("📂 Routines loaded from file: \(routines.count) items")
            return routines
        } catch {
            print("📂 No routines file found or failed to load: \(error)")
            return []
        }
    }
    
    // MARK: - Templates (Kaldırıldı)
    // Şablon sistemi kaldırıldı
    
    // MARK: - Debug
    
    func printFileStatus() {
        print("📁 FILE STATUS:")
        print("📁 Projects file exists: \(FileManager.default.fileExists(atPath: projectsFile.path))")
        print("📁 Routines file exists: \(FileManager.default.fileExists(atPath: routinesFile.path))")
    }
}
