//
//  RoutineModel.swift
//  TodoWidget
//
//  Created by Macbook Air on 21.10.2025.
//

import Foundation

// Widget için basit Routine modeli
struct RoutineModel: Identifiable, Codable {
    let id: UUID
    let title: String
    let isCompleted: Bool
    let lastCompletedDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, title, isCompleted, lastCompletedDate
    }
}
