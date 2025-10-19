//
//  Project.swift
//  to do app
//
//  Created by Macbook Air on 19.10.2025.
//
import Foundation

enum Priority: String, Codable, CaseIterable {
    case high = "Yüksek Öncelik"
    case medium = "Orta Öncelik"
    case low = "Düşük Öncelik"
    
    var color: String {
        switch self {
        case .high: return "red"
        case .medium: return "orange"
        case .low: return "green"
        }
    }
}

struct Project: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var priority: Priority
    var deadline: Date?
    var duration: String
    var isCompleted: Bool = false
    var icon: String = "📋" // Varsayılan emoji
    
    var deadlineString: String {
        guard let deadline = deadline else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: deadline)
    }
}
