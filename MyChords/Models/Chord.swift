import Foundation

final class Chord {
    var name: String
    var symbol: String
    var notes: [Note]
    
    init(name: String, symbol: String, notes: [Note]) {
        self.name = name
        self.symbol = symbol
        self.notes = notes
    }
    
    static func createMajorChord(root: String, octave: Int = 4) -> Chord {
        let intervals = [0, 4, 7]
        let notes = intervals.map { interval in
            let noteName = transposeNote(root, semitonesUp: interval)
            let noteOctave = octave + (getStartingNoteIndex(root) + interval) / 12
            return Note(name: noteName, octave: noteOctave)
        }
        return Chord(name: "\(root) Major", symbol: root, notes: notes)
    }
    
    private static func getStartingNoteIndex(_ note: String) -> Int {
        let noteOrder = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        return noteOrder.firstIndex(of: note) ?? 0
    }
    
    private static func transposeNote(_ note: String, semitonesUp: Int) -> String {
        let noteOrder = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        guard let index = noteOrder.firstIndex(of: note) else { return note }
        let newIndex = (index + semitonesUp) % 12
        return noteOrder[newIndex]
    }
}
