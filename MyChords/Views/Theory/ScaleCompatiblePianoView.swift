import SwiftUI

// Piano keyboard view that can handle both sharp and flat note names
struct ScaleCompatiblePianoKeyboardView: View {
    let highlightedNotes: Set<String>
    let rootNote: String
    let octave: Int
    let keyWidth: CGFloat = 32
    
    // Map any note name to its chromatic position (0-11)
    private func noteToChromatic(_ note: String) -> Int {
        let noteMap: [String: Int] = [
            "C": 0, "B#": 0,
            "C#": 1, "Db": 1,
            "D": 2,
            "D#": 3, "Eb": 3,
            "E": 4, "Fb": 4,
            "E#": 5, "F": 5,
            "F#": 6, "Gb": 6,
            "G": 7,
            "G#": 8, "Ab": 8,
            "A": 9,
            "A#": 10, "Bb": 10,
            "B": 11, "Cb": 11
        ]
        return noteMap[note] ?? -1
    }
    
    // Convert chromatic position back to note name (using sharps)
    private func chromaticToNote(_ index: Int) -> String {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        return notes[index % 12]
    }
    
    // Check if a chromatic position is a black key
    private func isBlackKey(_ chromaticIndex: Int) -> Bool {
        return [1, 3, 6, 8, 10].contains(chromaticIndex % 12)
    }
    
    // Check if any of the highlighted notes match this chromatic position
    private func isHighlighted(_ chromaticIndex: Int) -> Bool {
        return highlightedNotes.contains { note in
            noteToChromatic(note) == chromaticIndex % 12
        }
    }
    
    // Generate piano keys starting from the root
    private var pianoKeys: [(chromaticIndex: Int, position: CGFloat, isBlack: Bool, isOctaveRoot: Bool)] {
        let rootIndex = noteToChromatic(rootNote)
        guard rootIndex >= 0 else { return [] }
        
        var keys: [(chromaticIndex: Int, position: CGFloat, isBlack: Bool, isOctaveRoot: Bool)] = []
        var whiteKeyPosition: CGFloat = 0
        
        // Generate 13 keys starting from root (to show octave)
        for i in 0..<13 {
            let chromaticIndex = (rootIndex + i) % 12
            let actualIndex = rootIndex + i // Keep track of actual position including octave
            let isBlack = isBlackKey(chromaticIndex)
            let isOctaveRoot = (i == 12) // The 13th key is the octave root
            
            if isBlack {
                // Black keys are positioned between white keys
                let blackPosition = whiteKeyPosition - 0.5
                keys.append((chromaticIndex: actualIndex, position: blackPosition, isBlack: true, isOctaveRoot: isOctaveRoot))
            } else {
                keys.append((chromaticIndex: actualIndex, position: whiteKeyPosition, isBlack: false, isOctaveRoot: isOctaveRoot))
                whiteKeyPosition += 1
            }
        }
        
        return keys
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Draw white keys first
            ForEach(Array(pianoKeys.filter { !$0.isBlack }.enumerated()), id: \.offset) { index, key in
                let noteName = chromaticToNote(key.chromaticIndex)
                ScaleCompatiblePianoKeyView(
                    chromaticIndex: key.chromaticIndex,
                    noteName: noteName,
                    isHighlighted: isHighlighted(key.chromaticIndex),
                    isOctaveRoot: key.isOctaveRoot,
                    isBlackKey: false,
                    keyWidth: keyWidth
                )
                .offset(x: key.position * (keyWidth + 1))
                .zIndex(0)
            }
            
            // Draw black keys on top
            ForEach(Array(pianoKeys.filter { $0.isBlack }.enumerated()), id: \.offset) { index, key in
                let noteName = chromaticToNote(key.chromaticIndex)
                ScaleCompatiblePianoKeyView(
                    chromaticIndex: key.chromaticIndex,
                    noteName: noteName,
                    isHighlighted: isHighlighted(key.chromaticIndex),
                    isOctaveRoot: key.isOctaveRoot,
                    isBlackKey: true,
                    keyWidth: keyWidth
                )
                .offset(x: key.position * (keyWidth + 1))
                .zIndex(1)
            }
        }
        .frame(height: keyWidth * 4)
    }
}

// Individual piano key that works with chromatic indices
struct ScaleCompatiblePianoKeyView: View {
    let chromaticIndex: Int
    let noteName: String
    let isHighlighted: Bool
    let isOctaveRoot: Bool
    let isBlackKey: Bool
    let keyWidth: CGFloat
    
    var keyColor: Color {
        if isOctaveRoot && isHighlighted {
            return .blue.opacity(0.5)
        } else if isHighlighted {
            return .blue
        } else if isBlackKey {
            return .black
        } else {
            return .white
        }
    }
    
    var textColor: Color {
        if isHighlighted || isBlackKey {
            return .white
        } else {
            return .black
        }
    }
    
    var body: some View {
        if isBlackKey {
            blackKeyView
        } else {
            whiteKeyView
        }
    }
    
    private var whiteKeyView: some View {
        Rectangle()
            .fill(keyColor)
            .frame(width: keyWidth, height: keyWidth * 4)
            .overlay(
                Rectangle()
                    .stroke(Color.black, lineWidth: 1)
            )
            .overlay(
                VStack {
                    Spacer()
                    VStack(spacing: 2) {
                        Text(noteName)
                            .font(.system(size: 12, weight: isHighlighted ? .bold : .regular))
                            .foregroundColor(textColor)
                        if isOctaveRoot {
                            Text("8ve")
                                .font(.system(size: 10))
                                .foregroundColor(textColor.opacity(0.8))
                        }
                    }
                    .padding(.bottom, 4)
                }
            )
    }
    
    private var blackKeyView: some View {
        Rectangle()
            .fill(keyColor)
            .frame(width: keyWidth * 0.6, height: keyWidth * 2.5)
            .overlay(
                Text(noteName)
                    .font(.system(size: 10, weight: isHighlighted ? .bold : .regular))
                    .foregroundColor(textColor)
                    .offset(y: keyWidth * 0.8)
            )
    }
}