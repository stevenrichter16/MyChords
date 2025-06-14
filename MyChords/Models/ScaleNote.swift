import Foundation

struct ScaleNote: Identifiable {
    let id = UUID()
    let note: String
    let degree: Int
    let degreeName: String
    let interval: String
    let isInChord: Bool
    
    init(note: String, degree: Int, interval: String, isInChord: Bool = false) {
        self.note = note
        self.degree = degree
        self.interval = interval
        self.isInChord = isInChord
        
        // Assign degree names
        switch degree {
        case 1: self.degreeName = "Tonic"
        case 2: self.degreeName = "Supertonic"
        case 3: self.degreeName = "Mediant"
        case 4: self.degreeName = "Subdominant"
        case 5: self.degreeName = "Dominant"
        case 6: self.degreeName = "Submediant"
        case 7: self.degreeName = "Leading Tone"
        default: self.degreeName = ""
        }
    }
}