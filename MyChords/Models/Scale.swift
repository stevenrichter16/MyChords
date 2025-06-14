import Foundation

enum ScaleType: String, CaseIterable {
    case major = "Major"
    case naturalMinor = "Natural Minor"
    case harmonicMinor = "Harmonic Minor"
    case melodicMinor = "Melodic Minor"
    case dorian = "Dorian"
    case phrygian = "Phrygian"
    case lydian = "Lydian"
    case mixolydian = "Mixolydian"
    case locrian = "Locrian"
    
    var intervals: [Int] {
        switch self {
        case .major:
            return [0, 2, 4, 5, 7, 9, 11]
        case .naturalMinor:
            return [0, 2, 3, 5, 7, 8, 10]
        case .harmonicMinor:
            return [0, 2, 3, 5, 7, 8, 11]
        case .melodicMinor:
            return [0, 2, 3, 5, 7, 9, 11]
        case .dorian:
            return [0, 2, 3, 5, 7, 9, 10]
        case .phrygian:
            return [0, 1, 3, 5, 7, 8, 10]
        case .lydian:
            return [0, 2, 4, 6, 7, 9, 11]
        case .mixolydian:
            return [0, 2, 4, 5, 7, 9, 10]
        case .locrian:
            return [0, 1, 3, 5, 6, 8, 10]
        }
    }
}

final class Scale {
    var name: String
    var rootNote: String
    var type: String // Store as String for SwiftData compatibility
    
    var scaleType: ScaleType {
        ScaleType(rawValue: type) ?? .major
    }
    
    var notes: [String] {
        // Use MusicTheoryService to get scale notes
        let scaleNotes = MusicTheoryService.shared.getMajorScale(root: rootNote)
        return scaleNotes.map { $0.note }
    }
    
    init(rootNote: String, type: ScaleType) {
        self.rootNote = rootNote
        self.type = type.rawValue
        self.name = "\(rootNote) \(type.rawValue)"
    }
    
    // Factory methods for common scales
    static func createMajorScale(root: String) -> Scale {
        return Scale(rootNote: root, type: .major)
    }
    
    static func createNaturalMinorScale(root: String) -> Scale {
        return Scale(rootNote: root, type: .naturalMinor)
    }
    
    static func createHarmonicMinorScale(root: String) -> Scale {
        return Scale(rootNote: root, type: .harmonicMinor)
    }
    
    // Generate scale notes with proper enharmonic spelling
    private static func generateScaleNotes(root: String, type: ScaleType) -> [String] {
        // For major scales, use proper key signature spellings
        if type == .major {
            switch root {
            case "C":
                return ["C", "D", "E", "F", "G", "A", "B"]
            case "G":
                return ["G", "A", "B", "C", "D", "E", "F#"]
            case "D":
                return ["D", "E", "F#", "G", "A", "B", "C#"]
            case "A":
                return ["A", "B", "C#", "D", "E", "F#", "G#"]
            case "E":
                return ["E", "F#", "G#", "A", "B", "C#", "D#"]
            case "B":
                return ["B", "C#", "D#", "E", "F#", "G#", "A#"]
            case "F#":
                return ["F#", "G#", "A#", "B", "C#", "D#", "E#"]
            case "F":
                return ["F", "G", "A", "Bb", "C", "D", "E"]
            case "Bb":
                return ["Bb", "C", "D", "Eb", "F", "G", "A"]
            case "Eb":
                return ["Eb", "F", "G", "Ab", "Bb", "C", "D"]
            case "Ab":
                return ["Ab", "Bb", "C", "Db", "Eb", "F", "G"]
            case "Db":
                return ["Db", "Eb", "F", "Gb", "Ab", "Bb", "C"]
            case "Gb":
                return ["Gb", "Ab", "Bb", "Cb", "Db", "Eb", "F"]
            default:
                // Fallback to chromatic generation
                return generateChromaticNotes(root: root, intervals: type.intervals)
            }
        } else {
            // For other scale types, generate based on intervals
            // This could be expanded with proper spellings for each scale type
            return generateChromaticNotes(root: root, intervals: type.intervals)
        }
    }
    
    // Generate notes chromatically (with sharps by default)
    private static func generateChromaticNotes(root: String, intervals: [Int]) -> [String] {
        intervals.map { interval in
            transposeNote(root, semitonesUp: interval)
        }
    }
    
    // Transpose a note by semitones (handles both sharps and flats)
    private static func transposeNote(_ note: String, semitonesUp: Int) -> String {
        // Convert any note to a chromatic index
        let chromaticIndex = noteToChromatic(note)
        let newIndex = (chromaticIndex + semitonesUp + 12) % 12
        
        // Return with the same accidental preference as input
        if note.contains("b") {
            return chromaticToNote(newIndex, preferFlats: true)
        } else {
            return chromaticToNote(newIndex, preferFlats: false)
        }
    }
    
    // Convert note name to chromatic index (0-11)
    private static func noteToChromatic(_ note: String) -> Int {
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
        return noteMap[note] ?? 0
    }
    
    // Convert chromatic index to note name
    private static func chromaticToNote(_ index: Int, preferFlats: Bool = false) -> String {
        let sharpNotes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let flatNotes = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]
        
        return preferFlats ? flatNotes[index] : sharpNotes[index]
    }
    
    // Get a chord built on a scale degree
    func getChordAtDegree(_ degree: Int, chordType: ChordType) -> Chord? {
        guard degree >= 1 && degree <= notes.count else { return nil }
        
        let rootIndex = degree - 1
        let rootNote = notes[rootIndex]
        
        // Generate chord using semitone intervals from the root
        let chordSemitones: [Int]
        let chordName: String
        let chordSymbol: String
        
        switch chordType {
        case .major:
            chordSemitones = [0, 4, 7] // Root, major 3rd, perfect 5th
            chordName = "\(rootNote) Major"
            chordSymbol = rootNote
        case .minor:
            chordSemitones = [0, 3, 7] // Root, minor 3rd, perfect 5th
            chordName = "\(rootNote) Minor"
            chordSymbol = rootNote
        case .major7:
            chordSemitones = [0, 4, 7, 11] // Root, major 3rd, perfect 5th, major 7th
            chordName = "\(rootNote) Major 7"
            chordSymbol = rootNote
        case .dominant7:
            chordSemitones = [0, 4, 7, 10] // Root, major 3rd, perfect 5th, minor 7th
            chordName = "\(rootNote) Dominant 7"
            chordSymbol = rootNote
        case .diminished:
            chordSemitones = [0, 3, 6] // Root, minor 3rd, diminished 5th
            chordName = "\(rootNote) Diminished"
            chordSymbol = rootNote
        }
        
        // Build chord notes using semitone transposition
        var chordNotes: [Note] = []
        for semitones in chordSemitones {
            let noteName = Scale.transposeNote(rootNote, semitonesUp: semitones)
            chordNotes.append(Note(name: noteName, octave: 4))
        }
        
        return Chord(name: chordName, symbol: chordSymbol, notes: chordNotes)
    }
}

enum ChordType {
    case major
    case minor
    case major7
    case dominant7
    case diminished
    
    var degreeNotation: String {
        switch self {
        case .major:
            return "1-3-5"
        case .minor:
            return "1-♭3-5"
        case .major7:
            return "1-3-5-7"
        case .dominant7:
            return "1-3-5-♭7"
        case .diminished:
            return "1-♭3-♭5"
        }
    }
}