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
}
