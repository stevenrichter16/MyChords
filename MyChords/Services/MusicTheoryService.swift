import Foundation

class MusicTheoryService {
    static let shared = MusicTheoryService()
    
    private init() {}
    
    // All notes in chromatic order
    private let chromaticNotes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    // Major scale intervals (in semitones from root)
    private let majorScaleIntervals = [0, 2, 4, 5, 7, 9, 11]
    private let majorScaleDegrees = [1, 2, 3, 4, 5, 6, 7]
    private let intervalNames = [
        0: "Root",
        2: "Major 2nd",
        4: "Major 3rd",
        5: "Perfect 4th",
        7: "Perfect 5th",
        9: "Major 6th",
        11: "Major 7th"
    ]
    
    func getMajorScale(root: String) -> [ScaleNote] {
        guard let rootIndex = chromaticNotes.firstIndex(of: root) else { return [] }
        
        var scaleNotes: [ScaleNote] = []
        
        for (index, interval) in majorScaleIntervals.enumerated() {
            let noteIndex = (rootIndex + interval) % 12
            let noteName = chromaticNotes[noteIndex]
            let degree = majorScaleDegrees[index]
            let intervalName = intervalNames[interval] ?? "Unknown"
            
            scaleNotes.append(ScaleNote(
                note: noteName,
                degree: degree,
                interval: intervalName
            ))
        }
        
        return scaleNotes
    }
    
    func getScaleWithChordHighlights(chord: Chord) -> [ScaleNote] {
        // For now, assume the chord root is the scale root (C major scale for C chord, etc.)
        let root = chord.symbol
        var scaleNotes = getMajorScale(root: root)
        
        // Create a set of chord note names for quick lookup
        let chordNoteNames = Set(chord.notes.map { $0.name })
        
        // Update scale notes to mark which ones are in the chord
        scaleNotes = scaleNotes.map { scaleNote in
            ScaleNote(
                note: scaleNote.note,
                degree: scaleNote.degree,
                interval: scaleNote.interval,
                isInChord: chordNoteNames.contains(scaleNote.note)
            )
        }
        
        return scaleNotes
    }
    
    func getChordFunction(chord: Chord, inKey: String) -> String {
        // This will be expanded later for full Roman numeral analysis
        // For now, return basic function based on scale degree
        let scaleDegree = getScaleDegree(of: chord.symbol, inKey: inKey)
        
        switch scaleDegree {
        case 1: return "I - Tonic (Home)"
        case 2: return "II - Supertonic"
        case 3: return "III - Mediant"
        case 4: return "IV - Subdominant (Departure)"
        case 5: return "V - Dominant (Tension)"
        case 6: return "VI - Submediant"
        case 7: return "VII - Leading Tone"
        default: return "Unknown Function"
        }
    }
    
    private func getScaleDegree(of chordRoot: String, inKey: String) -> Int {
        guard let keyIndex = chromaticNotes.firstIndex(of: inKey),
              let chordIndex = chromaticNotes.firstIndex(of: chordRoot) else { return 0 }
        
        let interval = (chordIndex - keyIndex + 12) % 12
        
        // Find which scale degree this interval corresponds to
        if let degreeIndex = majorScaleIntervals.firstIndex(of: interval) {
            return majorScaleDegrees[degreeIndex]
        }
        
        return 0
    }
    
    func getRelativeMinor(forMajorKey key: String) -> Chord {
        // The relative minor is at the 6th degree of the major scale
        guard let keyIndex = chromaticNotes.firstIndex(of: key) else {
            return Chord(name: "Unknown", symbol: "?", notes: [])
        }
        
        // 6th degree is 9 semitones up from the root
        let relativeMinorIndex = (keyIndex + 9) % 12
        let relativeMinorRoot = chromaticNotes[relativeMinorIndex]
        
        // Create a minor chord (root, minor 3rd, perfect 5th)
        let minorIntervals = [0, 3, 7]
        let notes = minorIntervals.map { interval in
            let noteIndex = (relativeMinorIndex + interval) % 12
            let noteName = chromaticNotes[noteIndex]
            return Note(name: noteName, octave: 4)
        }
        
        return Chord(
            name: "\(relativeMinorRoot) Minor",
            symbol: "\(relativeMinorRoot)m",
            notes: notes
        )
    }
    
    func getDominant(forMajorKey key: String) -> Chord {
        // The dominant is at the 5th degree of the major scale
        guard let keyIndex = chromaticNotes.firstIndex(of: key) else {
            return Chord(name: "Unknown", symbol: "?", notes: [])
        }
        
        // 5th degree is 7 semitones up from the root
        let dominantIndex = (keyIndex + 7) % 12
        let dominantRoot = chromaticNotes[dominantIndex]
        
        // Create a major chord (root, major 3rd, perfect 5th)
        let majorIntervals = [0, 4, 7]
        let notes = majorIntervals.map { interval in
            let noteIndex = (dominantIndex + interval) % 12
            let noteName = chromaticNotes[noteIndex]
            return Note(name: noteName, octave: 4)
        }
        
        return Chord(
            name: "\(dominantRoot) Major",
            symbol: dominantRoot,
            notes: notes
        )
    }
    
    func getDominant7(forMajorKey key: String) -> Chord {
        // The dominant 7 is at the 5th degree with an added minor 7th
        guard let keyIndex = chromaticNotes.firstIndex(of: key) else {
            return Chord(name: "Unknown", symbol: "?", notes: [])
        }
        
        // 5th degree is 7 semitones up from the root
        let dominantIndex = (keyIndex + 7) % 12
        let dominantRoot = chromaticNotes[dominantIndex]
        
        // Create a dominant 7 chord (root, major 3rd, perfect 5th, minor 7th)
        let dom7Intervals = [0, 4, 7, 10]
        let notes = dom7Intervals.map { interval in
            let noteIndex = (dominantIndex + interval) % 12
            let noteName = chromaticNotes[noteIndex]
            return Note(name: noteName, octave: 4)
        }
        
        return Chord(
            name: "\(dominantRoot) Dominant 7",
            symbol: "\(dominantRoot)7",
            notes: notes
        )
    }
}