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
    
    private override init() {
        super.init()
    }
    
    private func playSound(named name: String, volume: Float = 0.7) {
        // INSTANT PLAYBACK - Checkbox'a tıkladığınız anda çalar!
        // Her tıklama bağımsız bir ses instance'ı oluşturur
        
        // Sistem seslerini kullan
        guard let sound = NSSound(named: name) else { 
            print("⚠️ Ses bulunamadı: \(name)")
            return 
        }
        
        // Ses seviyesini ayarla
        sound.volume = volume
        
        // ANINDA çal - hiçbir gecikme yok!
        DispatchQueue.main.async {
            sound.play()
        }
    }
    
    // stopAllSounds kaldırıldı - artık spam koruması yok
    
    func playTaskCompleteSound() {
        // ✨ CHECKBOX TAMAMLAMA - Tatmin edici "tink" sesi
        playSound(named: "Tink", volume: 0.9)
    }
    
    func playTaskAddSound() {
        // ➕ YENİ GÖREV - Hafif pop sesi
        playSound(named: "Pop", volume: 0.7)
    }
    
    func playTaskDeleteSound() {
        // 🗑️ SİLME - Swoosh sesi
        playSound(named: "Bottle", volume: 0.6)
    }
    
    func playSuccessSound() {
        // 🎉 BAŞARI - Etkileyici ses
        playSound(named: "Glass", volume: 1.0)
    }
    
    func playRoutineCompleteSound() {
        // ✅ RUTİN TAMAMLAMA - Pozitif ses
        playSound(named: "Purr", volume: 0.8)
    }
    
    func playAllRoutinesCompleteSound() {
        // 🏆 TÜM RUTİNLER - Zafer sesi!
        playSound(named: "Glass", volume: 1.0)
    }
    
    // Haptic feedback for checkboxes
    func playHapticFeedback() {
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
    }
}

// NSSoundDelegate kaldırıldı - artık gerekli değil
