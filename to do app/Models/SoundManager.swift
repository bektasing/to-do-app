//
//  SoundManager.swift
//  to do app
//
//  Created by Macbook Air on 19.10.2025.
//

import AVFoundation
import AppKit

class SoundManager {
    static let shared = SoundManager()
    
    private init() {}
    
    func playTaskCompleteSound() {
        NSSound(named: "Glass")?.play()
    }
    
    func playTaskAddSound() {
        NSSound(named: "Pop")?.play()
    }
    
    func playTaskDeleteSound() {
        NSSound(named: "Funk")?.play()
    }
    
    func playSuccessSound() {
        NSSound(named: "Hero")?.play()
    }
}
