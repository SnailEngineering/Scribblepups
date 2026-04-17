import SwiftUI

struct StickerPicker: View {
    @Binding var toolMode: ToolMode

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Sticker.allCases) { sticker in
                    let isSelected: Bool = {
                        if case .stamp(let s) = toolMode { return s == sticker }
                        return false
                    }()

                    Button {
                        toolMode = .stamp(sticker)
                        Haptics.selection()
                    } label: {
                        Text(sticker.emoji)
                            .font(.system(size: 32))
                            .frame(width: 48, height: 48)
                            .scaleEffect(isSelected ? 1.2 : 1.0)
                            .background(isSelected ? Color.accentColor.opacity(0.2) : .clear)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(sticker.rawValue)
                    .animation(.spring(duration: 0.2), value: isSelected)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 60)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 8)
    }
}
