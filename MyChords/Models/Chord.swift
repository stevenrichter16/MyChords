import Foundation

final class Chord {
    var name: String
    var symbol: String
    var notes: [Note]
    var inversion: Int = 0  // 0 = root position, 1 = first inversion, 2 = second inversion, etc.
    
    init(name: String, symbol: String, notes: [Note], inversion: Int = 0) {
        self.name = name
        self.symbol = symbol
        self.notes = notes
        self.inversion = inversion
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
    
    // Create a chord inversion
    func inverted(inversion: Int) -> Chord {
        guard inversion > 0 && inversion < notes.count else {
            // Return root position if invalid inversion requested
            return Chord(name: name, symbol: symbol, notes: notes, inversion: 0)
        }
        
        var invertedNotes: [Note] = []
        
        // For each position in the inverted chord
        for i in 0..<notes.count {
            if i < notes.count - inversion {
                // These notes stay in their original octave
                // They come from positions (inversion) through (count-1) in the original
                let sourceIndex = i + inversion
                invertedNotes.append(notes[sourceIndex])
            } else {
                // These notes were moved from the bottom and need octave+1
                // They come from positions 0 through (inversion-1) in the original
                let sourceIndex = i - (notes.count - inversion)
                let originalNote = notes[sourceIndex]
                invertedNotes.append(Note(name: originalNote.name, octave: originalNote.octave + 1))
            }
        }
        
        // Update the name to reflect the inversion
        let inversionNames = ["Root Position", "1st Inversion", "2nd Inversion", "3rd Inversion"]
        let inversionName = inversion < inversionNames.count ? inversionNames[inversion] : "\(inversion)th Inversion"
        let newName = "\(name) (\(inversionName))"
        
        return Chord(name: newName, symbol: symbol, notes: invertedNotes, inversion: inversion)
    }
    
    // Get the bass note (lowest note) of the chord
    var bassNote: Note? {
        return notes.first
    }
    
    // Get inversion display name
    var inversionName: String {
        let names = ["Root Position", "1st Inversion", "2nd Inversion", "3rd Inversion"]
        return inversion < names.count ? names[inversion] : "\(inversion)th Inversion"
    }
}
