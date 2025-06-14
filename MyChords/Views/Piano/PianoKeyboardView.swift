import SwiftUI

struct PianoKeyboardView: View {
    let highlightedNotes: Set<String>
    let octave: Int
    let keyWidth: CGFloat = 20
    
    // New property to support exact note positions
    let highlightedNotePositions: Set<String>?
    
    // Standard piano key pattern for one octave
    let whiteKeys = ["C", "D", "E", "F", "G", "A", "B"]
    let blackKeyPositions = ["C#": 0.5, "D#": 1.5, "F#": 3.5, "G#": 4.5, "A#": 5.5]
    
    // Computed property to determine octave range
    private var octaveRange: ClosedRange<Int> {
        // If we have specific note positions, calculate the range
        if let positions = highlightedNotePositions {
            var minOctave = octave
            var maxOctave = octave
            
            for position in positions {
                // Extract octave from strings like "C4", "E5"
                if let lastChar = position.last, let noteOctave = Int(String(lastChar)) {
                    minOctave = min(minOctave, noteOctave)
                    maxOctave = max(maxOctave, noteOctave)
                }
            }
            
            // For inversions, we typically don't need to go lower than the original octave
            // But we do need to show the extended range to the right
            // Only go left if we have notes there (e.g., for bass clef or special voicings)
            let startOctave = minOctave < octave ? minOctave : octave
            // Add a bit of padding to the right to show context
            let endOctave = maxOctave > octave ? min(7, maxOctave) : octave
            
            return startOctave...endOctave
        }
        
        // Default to single octave
        return octave...octave
    }
    
    // Initialize with backward compatibility
    init(highlightedNotes: Set<String>, octave: Int = 4, highlightedNotePositions: Set<String>? = nil) {
        self.highlightedNotes = highlightedNotes
        self.octave = octave
        self.highlightedNotePositions = highlightedNotePositions
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(octaveRange), id: \.self) { currentOctave in
                ZStack(alignment: .topLeading) {
                    // White keys for this octave
                    HStack(spacing: 1) {
                        ForEach(whiteKeys, id: \.self) { note in
                            let isHighlighted = shouldHighlightKey(note: note, octave: currentOctave)
                            
                            PianoKeyView(
                                note: note,
                                isHighlighted: isHighlighted,
                                keyWidth: keyWidth
                            )
                            .overlay(alignment: .bottom) {
                                // Show octave number on C keys
                                if note == "C" {
                                    Text("\(currentOctave)")
                                        .font(.system(size: 8))
                                        .foregroundColor(.gray)
                                        .padding(.bottom, 2)
                                }
                            }
                        }
                    }
                    
                    // Black keys for this octave
                    ForEach(blackKeyPositions.keys.sorted(), id: \.self) { note in
                        let isHighlighted = shouldHighlightKey(note: note, octave: currentOctave)
                        
                        PianoKeyView(
                            note: note,
                            isHighlighted: isHighlighted,
                            keyWidth: keyWidth
                        )
                        .offset(x: (blackKeyPositions[note]! * (keyWidth + 1)) + (keyWidth * 0.2))
                    }
                }
                
                // Add a small separator between octaves
                if currentOctave < octaveRange.upperBound {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1, height: keyWidth * 4)
                }
            }
        }
        .frame(height: keyWidth * 4)
    }
    
    private func shouldHighlightKey(note: String, octave: Int) -> Bool {
        // First check if we have specific positions
        if let positions = highlightedNotePositions {
            return positions.contains("\(note)\(octave)")
        }
        
        // Fall back to note name matching (backward compatibility)
        return highlightedNotes.contains(note)
    }
}