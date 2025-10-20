//
//  SoundManager.swift
//  to do app
//
//  Created by Macbook Air on 19.10.2025.
//

import AVFoundation
import AppKit

class SoundManager: NSObject {
    static let shared = SoundManager()
    
    private var soundQueue: [NSSound] = []
    private var isPlaying = false
    
    private override init() {
        super.init()
    }
    
    private func playSound(named name: String) {
        guard let sound = NSSound(named: name) else { return }
        
        // Önceki sesi durdur ve yeni sesi çal
        stopAllSounds()
        sound.play()
    }
    
    private func stopAllSounds() {
        // Tüm sesleri durdur - NSSound'ta stopAll() yok, queue'yu temizle
        soundQueue.removeAll()
        isPlaying = false
    }
    
    func playTaskCompleteSound() {
        playSound(named: "Glass")
    }
    
    func playTaskAddSound() {
        playSound(named: "Pop")
    }
    
    func playTaskDeleteSound() {
        playSound(named: "Funk")
    }
    
    func playSuccessSound() {
        playSound(named: "Hero")
    }
}

// Delegate extension
// MARK: - NSSoundDelegate (Artık gerekli değil)
// extension SoundManager: NSSoundDelegate {
//     func sound(_ sound: NSSound, didFinishPlaying flag: Bool) {
//         // Artık queue sistemi kullanmıyoruz
//     }
// }
