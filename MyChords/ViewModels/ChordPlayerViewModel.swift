import SwiftUI
import Observation

@Observable
final class ChordPlayerViewModel {
    private let audioEngine = AudioEngine()
    
    var availableChords: [Chord] = []
    var chordProgressions: [ChordProgression] = []
    var currentlyPlayingChordId: String?
    var currentlyPlayingProgressionId: UUID?
    var currentlyPlayingProgressionIndex: Int?
    var currentProgressionTask: Task<Void, Never>?
    
    var isPlaying: Bool {
        audioEngine.isPlaying
    }
    
    init() {
        setupChords()
        setupProgressions()
    }
    
    private func setupChords() {
        availableChords = [
            Chord.createMajorChord(root: "C"),
            Chord.createMajorChord(root: "D"),
            Chord.createMajorChord(root: "E"),
            Chord.createMajorChord(root: "F"),
            Chord.createMajorChord(root: "G"),
            Chord.createMajorChord(root: "A"),
            Chord.createMajorChord(root: "B")
        ]
    }
    
    func playChord(_ chord: Chord) {
        currentlyPlayingChordId = chord.name
        audioEngine.playChord(chord)
        
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if currentlyPlayingChordId == chord.name {
                currentlyPlayingChordId = nil
            }
        }
    }
    
    func stopPlayback() {
        currentProgressionTask?.cancel()
        currentProgressionTask = nil
        audioEngine.stopCurrentPlayback()
        currentlyPlayingChordId = nil
        currentlyPlayingProgressionId = nil
        currentlyPlayingProgressionIndex = nil
    }
    
    func playProgression(_ progression: ChordProgression) {
        stopPlayback()
        currentlyPlayingProgressionId = progression.id
        
        currentProgressionTask = Task { @MainActor in
            for (index, chord) in progression.chords.enumerated() {
                guard !Task.isCancelled else { break }
                
                // Update the index on main thread
                currentlyPlayingProgressionIndex = index
                
                // Play the chord
                audioEngine.playChord(chord, duration: 2.0)
                
                // Wait for the chord to finish
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                
                guard !Task.isCancelled else { break }
            }
            
            // Clear all states when done
            currentlyPlayingChordId = nil
            currentlyPlayingProgressionId = nil
            currentlyPlayingProgressionIndex = nil
            currentProgressionTask = nil
        }
    }
    
    private func setupProgressions() {
        chordProgressions = [
            ChordProgression(
                name: "I-V-vi-IV (Pop Progression)",
                description: "The most popular progression in modern music",
                chordSymbols: ["C", "G", "A", "F"]
            ),
            ChordProgression(
                name: "I-IV-V (12-Bar Blues)",
                description: "Classic rock and blues foundation",
                chordSymbols: ["C", "F", "G"]
            ),
            ChordProgression(
                name: "I-V-IV-V (Classic Rock)",
                description: "Timeless rock progression",
                chordSymbols: ["C", "G", "F", "G"]
            ),
            ChordProgression(
                name: "I-IV-I-V (Folk/Country)",
                description: "Simple and effective folk pattern",
                chordSymbols: ["G", "C", "G", "D"]
            ),
            ChordProgression(
                name: "I-VI-II-V (Jazz Turnaround)",
                description: "Common jazz progression",
                chordSymbols: ["C", "A", "D", "G"]
            ),
            ChordProgression(
                name: "I-III-IV-V (Ascending)",
                description: "Uplifting progression",
                chordSymbols: ["C", "E", "F", "G"]
            ),
            ChordProgression(
                name: "I-V-VI-IV (Alternative)",
                description: "Modern alternative rock",
                chordSymbols: ["G", "D", "E", "C"]
            ),
            ChordProgression(
                name: "I-II-IV-V (Beatles Style)",
                description: "Classic 60s progression",
                chordSymbols: ["C", "D", "F", "G"]
            ),
            ChordProgression(
                name: "I-bVII-IV-I (Rock Anthem)",
                description: "Stadium rock sound",
                chordSymbols: ["C", "B", "F", "C"]
            ),
            ChordProgression(
                name: "I-IV-V-IV (Doo-Wop)",
                description: "50s and 60s classic",
                chordSymbols: ["C", "F", "G", "F"]
            )
        ]
    }
}