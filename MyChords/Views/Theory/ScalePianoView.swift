import SwiftUI

struct ScalePianoView: View {
    let scaleNotes: [ScaleNote]
    let chord: Chord
    
    private var scaleNoteSet: Set<String> {
        Set(scaleNotes.map { $0.note })
    }
    
    private var chordNoteSet: Set<String> {
        Set(chord.notes.map { $0.name })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(chord.symbol) Major Scale - Piano View")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                // Chord notes piano
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 12, height: 12)
                        Text("Chord notes (\(chord.symbol) Major)")
                            .font(.subheadline)
                    }
                    
                    ScalePianoKeyboardView(
                        scaleNotes: Set<String>(), // Empty set for scale notes
                        chordNotes: chordNoteSet,
                        rootNote: chord.symbol,
                        octave: 4
                    )
                    .frame(height: 120)
                }
                
                // Scale notes piano
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green.opacity(0.7))
                            .frame(width: 12, height: 12)
                        Text("All scale notes (\(chord.symbol) Major Scale)")
                            .font(.subheadline)
                    }
                    
                    ScalePianoKeyboardView(
                        scaleNotes: scaleNoteSet,
                        chordNotes: Set<String>(), // Empty set - show all scale notes in same color
                        rootNote: chord.symbol,
                        octave: 4
                    )
                    .frame(height: 120)
                }
                
                Text("The last note (marked '8ve') is the octave of the root")
                    .font(.caption2)
                    .italic()
                    .foregroundColor(.secondary)
            }
        }
    }
}

// Custom piano keyboard that can show both scale notes and chord notes differently
struct ScalePianoKeyboardView: View {
    let scaleNotes: Set<String>
    let chordNotes: Set<String>
    let rootNote: String
    let octave: Int
    let keyWidth: CGFloat = 32
    
    // Convert note name to chromatic index (0-11)
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
    
    // Generate piano keys starting from the root
    private var pianoKeys: [(note: String, position: CGFloat, isBlack: Bool, isOctaveRoot: Bool)] {
        let chromaticNotes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        
        // Convert root note to chromatic index
        let rootIndex = noteToChromatic(rootNote)
        guard rootIndex >= 0 else { return [] }
        
        var keys: [(note: String, position: CGFloat, isBlack: Bool, isOctaveRoot: Bool)] = []
        var whiteKeyPosition: CGFloat = 0
        var lastWasWhite = true
        
        // Generate 13 keys starting from root (to show octave)
        for i in 0..<13 {
            let noteIndex = (rootIndex + i) % 12
            let note = chromaticNotes[noteIndex]
            let isBlack = note.contains("#")
            let isOctaveRoot = (i == 12) // The 13th key is the octave root
            
            if isBlack {
                // Black keys are positioned between white keys
                let blackPosition = whiteKeyPosition - 0.3
                keys.append((note: note, position: blackPosition, isBlack: true, isOctaveRoot: isOctaveRoot))
                lastWasWhite = false
            } else {
                // White keys increment position
                if !lastWasWhite {
                    // If previous was black, we're already at the right position
                }
                keys.append((note: note, position: whiteKeyPosition, isBlack: false, isOctaveRoot: isOctaveRoot))
                whiteKeyPosition += 1
                lastWasWhite = true
            }
        }
        
        return keys
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Draw all keys based on dynamic arrangement
            ForEach(Array(pianoKeys.enumerated()), id: \.offset) { index, key in
                ScalePianoKeyView(
                    note: key.note,
                    isInScale: scaleNotes.contains(key.note),
                    isInChord: chordNotes.contains(key.note),
                    isOctaveRoot: key.isOctaveRoot,
                    keyWidth: keyWidth
                )
                .offset(x: key.position * (keyWidth + 1))
                .zIndex(key.isBlack ? 1 : 0) // Black keys on top
            }
        }
        .frame(height: keyWidth * 4)
    }
}

// Piano key that can show scale membership and chord membership
struct ScalePianoKeyView: View {
    let note: String
    let isInScale: Bool
    let isInChord: Bool
    let isOctaveRoot: Bool
    let keyWidth: CGFloat
    
    var isBlackKey: Bool {
        // Check if it's a black key based on chromatic position
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
        let chromaticIndex = noteMap[note] ?? -1
        return [1, 3, 6, 8, 10].contains(chromaticIndex)
    }
    
    var keyColor: Color {
        if isOctaveRoot {
            // Octave root gets special styling
            if isInChord {
                return .blue.opacity(0.5)
            } else if isInScale {
                return .green.opacity(0.4)
            } else if isBlackKey {
                return .gray
            } else {
                return Color(.systemGray5)
            }
        } else if isInChord {
            return .blue
        } else if isInScale {
            return .green.opacity(0.7)
        } else if isBlackKey {
            return .black
        } else {
            return .white
        }
    }
    
    var textColor: Color {
        if isInScale || isInChord {
            return .white
        } else if isBlackKey {
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
                        Text(note)
                            .font(.system(size: 12, weight: isInScale ? .bold : .regular))
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
                Text(note)
                    .font(.system(size: 10, weight: isInScale ? .bold : .regular))
                    .foregroundColor(textColor)
                    .offset(y: keyWidth * 0.8)
            )
    }
}
