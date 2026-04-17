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
            HStack(spacing: 8) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .strokeBorder(
                            selectedColor == color ? Color.primary : Color.clear,
                            lineWidth: 3
                        )
                        .frame(width: 44, height: 44)
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 56)
    }
}
