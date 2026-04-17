import SwiftUI

struct ConfettiOverlay: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Text(particle.emoji)
                    .font(.system(size: particle.size))
                    .offset(
                        x: animate ? particle.endX : 0,
                        y: animate ? particle.endY : -20
                    )
                    .opacity(animate ? 0 : 1)
                    .rotationEffect(.degrees(animate ? particle.rotation : 0))
            }
        }
        .onAppear {
            particles = (0..<20).map { _ in ConfettiParticle() }
            withAnimation(.easeOut(duration: 1.5)) {
                animate = true
            }
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    let emoji: String
    let size: CGFloat
    let endX: CGFloat
    let endY: CGFloat
    let rotation: Double

    private static let emojis = ["🎉", "⭐️", "🌟", "✨", "💫", "🎊", "🌈", "💖"]

    init() {
        emoji = Self.emojis.randomElement()!
        size = CGFloat.random(in: 16...32)
        endX = CGFloat.random(in: -160...160)
        endY = CGFloat.random(in: 60...300)
        rotation = Double.random(in: -360...360)
    }
}
