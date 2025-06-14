import SwiftUI

struct ChordButtonWithPianoView: View {
    let chord: Chord
    let isPlaying: Bool
    let showPiano: Bool
    let action: () -> Void
    
    private var chordNoteSet: Set<String> {
        Set(chord.notes.map { $0.name })
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(chord.symbol)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(chord.name)
                    .font(.caption)
                
                if showPiano {
                    PianoKeyboardView(
                        highlightedNotes: chordNoteSet,
                        octave: 4
                    )
                    .scaleEffect(0.7)
                    .frame(height: 60)
                    .allowsHitTesting(false)
                } else {
                    Text(chord.notes.map { $0.name }.joined(separator: " - "))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: showPiano ? 160 : 120)
            .padding(.vertical, showPiano ? 8 : 0)
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