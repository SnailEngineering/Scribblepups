import SwiftUI

struct BrushPicker: View {
    @Binding var selectedBrush: BrushType
    @Binding var lineWidth: CGFloat

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ForEach(BrushType.allCases) { brush in
                    Button {
                        selectedBrush = brush
                        lineWidth = brush.defaultLineWidth
                    } label: {
                        Image(systemName: brush.iconName)
                            .font(.title2)
                            .frame(width: 48, height: 48)
                            .background(
                                selectedBrush == brush
                                    ? Color.accentColor.opacity(0.2)
                                    : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(brush.displayName)
                }
            }

            HStack {
                Image(systemName: "circle.fill")
                    .font(.caption2)
                Slider(value: $lineWidth, in: 2...30, step: 1)
                Image(systemName: "circle.fill")
                    .font(.title3)
            }
            .padding(.horizontal, 12)
        }
    }
}
