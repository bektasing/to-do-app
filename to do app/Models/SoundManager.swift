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
    
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    
    private override init() {
        super.init()
    }
    
    private func playSound(named name: String, volume: Float = 0.7) {
        // Önceki sesi durdur
        stopAllSounds()
        
        // Sistem seslerini kullan
        guard let sound = NSSound(named: name) else { return }
        
        // Ses seviyesini ayarla
        sound.volume = volume
        
        // Smooth playback için delegate kullan
        sound.delegate = self
        sound.play()
        isPlaying = true
    }
    
    private func stopAllSounds() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
    
    func playTaskCompleteSound() {
        // Daha iyi tamamlama sesi
        playSound(named: "Glass", volume: 0.8)
    }
    
    func playTaskAddSound() {
        playSound(named: "Pop", volume: 0.6)
    }
    
    func playTaskDeleteSound() {
        playSound(named: "Funk", volume: 0.5)
    }
    
    func playSuccessSound() {
        // Daha etkileyici başarı sesi
        playSound(named: "Hero", volume: 0.9)
    }
    
    func playRoutineCompleteSound() {
        // Rutin tamamlama için özel ses
        playSound(named: "Ping", volume: 0.7)
    }
    
    func playAllRoutinesCompleteSound() {
        // Tüm rutinler tamamlandığında özel ses
        playSound(named: "Hero", volume: 1.0)
    }
    
    // Haptic feedback for checkboxes
    func playHapticFeedback() {
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
    }
}

// Delegate extension
// MARK: - NSSoundDelegate
extension SoundManager: NSSoundDelegate {
    func sound(_ sound: NSSound, didFinishPlaying flag: Bool) {
        isPlaying = false
    }
}
