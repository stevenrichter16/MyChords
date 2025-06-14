import SwiftUI

struct PianoKeyboardView: View {
    let highlightedNotes: Set<String>
    let octave: Int
    let keyWidth: CGFloat = 20
    
    // Standard piano key pattern for one octave
    let whiteKeys = ["C", "D", "E", "F", "G", "A", "B"]
    let blackKeyPositions = ["C#": 0.5, "D#": 1.5, "F#": 3.5, "G#": 4.5, "A#": 5.5]
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // White keys
            HStack(spacing: 1) {
                ForEach(whiteKeys, id: \.self) { note in
                    PianoKeyView(
                        note: note,
                        isHighlighted: highlightedNotes.contains(note),
                        keyWidth: keyWidth
                    )
                }
            }
            
            // Black keys
            ForEach(blackKeyPositions.keys.sorted(), id: \.self) { note in
                PianoKeyView(
                    note: note,
                    isHighlighted: highlightedNotes.contains(note),
                    keyWidth: keyWidth
                )
                .offset(x: (blackKeyPositions[note]! * (keyWidth + 1)) + (keyWidth * 0.2))
            }
        }
        .frame(height: keyWidth * 4)
    }
}