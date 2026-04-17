import SwiftUI

struct ColorPalette: View {
    @Binding var selectedColor: Color

    private let colors: [Color] = [
        .black, .gray, .brown,
        .red, .orange, .yellow,
        .green, .mint, .cyan,
        .blue, .indigo, .purple,
        .pink, .white
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(colors, id: \.self) { color in
                    let isSelected = selectedColor == color
                    Circle()
                        .fill(color)
                        .overlay {
                            Circle()
                                .strokeBorder(Color.primary.opacity(0.3), lineWidth: color == .white ? 1 : 0)
                        }
                        .frame(width: 44, height: 44)
                        .scaleEffect(isSelected ? 1.2 : 1.0)
                        .overlay {
                            if isSelected {
                                Circle()
                                    .strokeBorder(.primary, lineWidth: 3)
                                    .frame(width: 50, height: 50)
                            }
                        }
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.2)) {
                                selectedColor = color
                            }
                            Haptics.selection()
                        }
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 60)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 8)
    }
}
