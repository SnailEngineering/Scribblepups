import SwiftUI

struct StickerPicker: View {
    @Binding var toolMode: ToolMode

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Sticker.allCases) { sticker in
                    let isSelected = {
                        if case .stamp(let s) = toolMode { return s == sticker }
                        return false
                    }()

                    Button {
                        toolMode = .stamp(sticker)
                    } label: {
                        Text(sticker.emoji)
                            .font(.system(size: 32))
                            .frame(width: 48, height: 48)
                            .background(
                                isSelected
                                    ? Color.accentColor.opacity(0.2)
                                    : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(sticker.rawValue)
                }
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 56)
    }
}
