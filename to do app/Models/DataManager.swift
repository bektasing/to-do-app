//
//  DataManager.swift
//  to do app
//
//  Created by Macbook Air on 19.10.2025.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    
    private let documentsDirectory: URL
    private let projectsFile: URL
    private let routinesFile: URL
    private let templatesFile: URL
    
    private init() {
        // Documents dizinini al
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Dosya yollarını oluştur
        projectsFile = documentsDirectory.appendingPathComponent("projects.json")
        routinesFile = documentsDirectory.appendingPathComponent("routines.json")
        templatesFile = documentsDirectory.appendingPathComponent("templates.json")
        
        print("📁 DataManager initialized")
        print("📁 Documents directory: \(documentsDirectory.path)")
        print("📁 Projects file: \(projectsFile.path)")
        print("📁 Routines file: \(routinesFile.path)")
        print("📁 Templates file: \(templatesFile.path)")
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
    
    // MARK: - Templates
    
    func saveTemplates(_ templates: [ProjectTemplate]) {
        do {
            let data = try JSONEncoder().encode(templates)
            try data.write(to: templatesFile)
            print("💾 Templates saved to file: \(templates.count) items")
        } catch {
            print("❌ Failed to save templates: \(error)")
        }
    }
    
    func loadTemplates() -> [ProjectTemplate] {
        do {
            let data = try Data(contentsOf: templatesFile)
            let templates = try JSONDecoder().decode([ProjectTemplate].self, from: data)
            print("📂 Templates loaded from file: \(templates.count) items")
            return templates
        } catch {
            print("📂 No templates file found or failed to load: \(error)")
            return []
        }
    }
    
    // MARK: - Debug
    
    func printFileStatus() {
        print("📁 FILE STATUS:")
        print("📁 Projects file exists: \(FileManager.default.fileExists(atPath: projectsFile.path))")
        print("📁 Routines file exists: \(FileManager.default.fileExists(atPath: routinesFile.path))")
        print("📁 Templates file exists: \(FileManager.default.fileExists(atPath: templatesFile.path))")
    }
}
