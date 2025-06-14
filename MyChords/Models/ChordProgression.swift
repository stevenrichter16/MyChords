import Foundation

struct ChordProgression: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let chords: [Chord]
    
    init(name: String, description: String, chordSymbols: [String]) {
        self.name = name
        self.description = description
        self.chords = chordSymbols.map { Chord.createMajorChord(root: $0) }
    }
}