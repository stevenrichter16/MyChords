import Foundation

final class Note {
    var name: String
    var octave: Int
    var frequency: Double
    var midiNumber: Int
    
    init(name: String, octave: Int) {
        self.name = name
        self.octave = octave
        let midi = Note.calculateMidiNumber(name: name, octave: octave)
        self.midiNumber = midi
        self.frequency = Note.midiToFrequency(midi)
    }
    
    static func calculateMidiNumber(name: String, octave: Int) -> Int {
        let noteValues = ["C": 0, "C#": 1, "D": 2, "D#": 3, "E": 4, "F": 5,
                         "F#": 6, "G": 7, "G#": 8, "A": 9, "A#": 10, "B": 11]
        let baseNote = noteValues[name] ?? 0
        return (octave + 1) * 12 + baseNote
    }
    
    static func midiToFrequency(_ midiNumber: Int) -> Double {
        return 440.0 * pow(2.0, Double(midiNumber - 69) / 12.0)
    }
}
