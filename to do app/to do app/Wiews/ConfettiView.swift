//
//  ConfettiView.swift
//  to do app
//
//  Created by Macbook Air on 19.10.2025.
//

import SwiftUI

struct ConfettiView: View {
    @State private var animate = false
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan, .mint, .indigo]
    
    var body: some View {
        ZStack {
            ForEach(0..<80, id: \.self) { index in
                ConfettiPiece(
                    color: colors.randomElement() ?? .blue,
                    delay: Double.random(in: 0...1.5),
                    duration: Double.random(in: 2.5...4.5),
                    startY: 200 // StatsCard'dan başla
                )
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                animate = true
            }
        }
    }
}

struct ConfettiPiece: View {
    let color: Color
    let delay: Double
    let duration: Double
    let startY: CGFloat
    
    @State private var yOffset: CGFloat = 0
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 8, height: 8)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .offset(x: xOffset, y: yOffset)
            .onAppear {
                // Başlangıç pozisyonu
                yOffset = startY
                xOffset = CGFloat.random(in: -150...150)
                
                withAnimation(
                    .easeOut(duration: duration)
                    .delay(delay)
                ) {
                    yOffset = -200 // Yukarıya doğru
                    xOffset = CGFloat.random(in: -300...300)
                    rotation = Double.random(in: 0...720) // Daha fazla dönüş
                }
                
                withAnimation(
                    .easeOut(duration: duration - 0.8)
                    .delay(delay + 0.8)
                ) {
                    opacity = 0
                }
            }
    }
}

#Preview {
    ConfettiView()
        .frame(width: 400, height: 600)
}
