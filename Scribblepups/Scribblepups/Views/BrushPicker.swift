import SwiftUI

struct BrushPicker: View {
    @Binding var selectedBrush: BrushType
    @Binding var lineWidth: CGFloat

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                ForEach(BrushType.allCases) { brush in
                    let isSelected = selectedBrush == brush
                    Button {
                        selectedBrush = brush
                        lineWidth = brush.defaultLineWidth
                        Haptics.selection()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: brush.iconName)
                                .font(.title2)
                                .frame(width: 44, height: 44)
                                .background(isSelected ? Color.accentColor.opacity(0.2) : .clear)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text(brush.displayName)
                                .font(.caption2)
                                .foregroundStyle(isSelected ? .primary : .secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(brush.displayName)
                }
            }

            HStack(spacing: 8) {
                Circle()
                    .fill(.primary)
                    .frame(width: 6, height: 6)
                Slider(value: $lineWidth, in: 2...30, step: 1)
                    .tint(.accentColor)
                Circle()
                    .fill(.primary)
                    .frame(width: 20, height: 20)
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 8)
    }
}
