//
//  Routine.swift
//  to do app
//
//  Created by Macbook Air on 19.10.2025.
//
import Foundation

struct Routine: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
    var lastCompletedDate: Date? = nil // Son tamamlanma tarihi
    
    /// Bugün tamamlanmış mı kontrol et
    var isCompletedToday: Bool {
        // Eğer hiç tamamlanmamışsa, bugün de tamamlanmamış sayılır
        guard let lastDate = lastCompletedDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }
}
