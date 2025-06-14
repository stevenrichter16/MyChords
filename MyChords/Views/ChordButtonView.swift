import SwiftUI

struct ChordButtonView: View {
    let chord: Chord
    let isPlaying: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(chord.symbol)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(chord.name)
                    .font(.caption)
                
                Text(chord.notes.map { $0.name }.joined(separator: " - "))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .foregroundColor(isPlaying ? .white : .primary)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isPlaying ? Color.blue : Color(.systemGray5))
                    .animation(.easeInOut(duration: 0.2), value: isPlaying)
            )
        }
        .buttonStyle(.plain)
        .disabled(isPlaying)
    }
}