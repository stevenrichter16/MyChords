# CLAUDE.md - Simple Chord Player iOS App

## Project Overview

This is a simple iOS chord player app built with SwiftUI, SwiftData, and the Observation framework. The app allows users to play four basic major chords (C, D, F, G) by tapping buttons. Each chord plays for 3 seconds using synthesized audio.

## Core Requirements

- **Single tab interface** with 4 chord buttons
- **Object-oriented design** with Note and Chord classes
- **3-second chord playback** when buttons are tapped
- **SwiftData ready** (no persistence yet, but structured for future use)
- **Observation framework** for state management (Combine only if absolutely necessary)
- **Extensible architecture** for future features

## Project Structure

```
SimpleChordPlayer/
├── App/
│   └── SimpleChordPlayerApp.swift
├── Models/
│   ├── Note.swift
│   ├── Chord.swift
│   └── MusicTheory.swift
├── Views/
│   ├── ContentView.swift
│   ├── ChordButtonView.swift
│   └── ChordPadView.swift
├── ViewModels/
│   └── ChordPlayerViewModel.swift
├── Audio/
│   ├── AudioEngine.swift
│   └── ChordSynthesizer.swift
└── Utilities/
    └── AudioConstants.swift
```

## Implementation Guidelines

### 1. App Entry Point

```swift
// SimpleChordPlayerApp.swift
import SwiftUI
import SwiftData

@main
struct SimpleChordPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Chord.self, Note.self])
    }
}
```

### 2. Models

#### Note Model
```swift
// Note.swift
import Foundation
import SwiftData

@Model
final class Note {
    var name: String
    var octave: Int
    var frequency: Double
    var midiNumber: Int
    
    init(name: String, octave: Int) {
        self.name = name
        self.octave = octave
        self.midiNumber = Note.calculateMidiNumber(name: name, octave: octave)
        self.frequency = Note.midiToFrequency(self.midiNumber)
    }
    
    // Helper methods for frequency calculation
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
```

#### Chord Model
```swift
// Chord.swift
import Foundation
import SwiftData

@Model
final class Chord {
    var name: String
    var symbol: String
    var notes: [Note]
    
    init(name: String, symbol: String, notes: [Note]) {
        self.name = name
        self.symbol = symbol
        self.notes = notes
    }
    
    // Factory method for creating basic chords
    static func createMajorChord(root: String, octave: Int = 4) -> Chord {
        let intervals = [0, 4, 7] // Major chord intervals
        let notes = intervals.map { interval in
            let noteName = transposeNote(root, semitonesUp: interval)
            return Note(name: noteName, octave: octave)
        }
        return Chord(name: "\(root) Major", symbol: root, notes: notes)
    }
    
    private static func transposeNote(_ note: String, semitonesUp: Int) -> String {
        let noteOrder = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        guard let index = noteOrder.firstIndex(of: note) else { return note }
        let newIndex = (index + semitonesUp) % 12
        return noteOrder[newIndex]
    }
}
```

### 3. Audio Engine

#### AudioEngine with AVFoundation (Simpler approach for now)
```swift
// AudioEngine.swift
import AVFoundation
import Observation

@Observable
final class AudioEngine {
    private var audioEngine = AVAudioEngine()
    private var playerNodes: [AVAudioPlayerNode] = []
    private let mixer: AVAudioMixerNode
    
    // Observable properties
    var isPlaying = false
    
    init() {
        mixer = audioEngine.mainMixerNode
        setupEngine()
    }
    
    private func setupEngine() {
        // Create player nodes for polyphony (one per note in chord)
        for _ in 0..<4 {
            let playerNode = AVAudioPlayerNode()
            audioEngine.attach(playerNode)
            audioEngine.connect(playerNode, to: mixer, format: nil)
            playerNodes.append(playerNode)
        }
        
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    func playChord(_ chord: Chord, duration: TimeInterval = 3.0) {
        stopCurrentPlayback()
        isPlaying = true
        
        for (index, note) in chord.notes.enumerated() where index < playerNodes.count {
            let buffer = createToneBuffer(frequency: note.frequency, duration: duration)
            playerNodes[index].scheduleBuffer(buffer) {
                DispatchQueue.main.async {
                    self.checkIfStillPlaying()
                }
            }
            playerNodes[index].play()
        }
    }
    
    func stopCurrentPlayback() {
        playerNodes.forEach { $0.stop() }
        isPlaying = false
    }
    
    private func checkIfStillPlaying() {
        let anyPlaying = playerNodes.contains { $0.isPlaying }
        isPlaying = anyPlaying
    }
    
    private func createToneBuffer(frequency: Double, duration: TimeInterval) -> AVAudioPCMBuffer {
        let sampleRate = 44100.0
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let buffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!, 
                                      frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        
        let data = buffer.floatChannelData![0]
        let amplitude: Float = 0.5
        let twoPi = 2 * Float.pi
        
        for frame in 0..<Int(frameCount) {
            let phase = Float(frame) * twoPi * Float(frequency) / Float(sampleRate)
            data[frame] = amplitude * sin(phase)
        }
        
        // Apply fade in/out to prevent clicks
        let fadeFrames = Int(sampleRate * 0.01) // 10ms fade
        for i in 0..<fadeFrames {
            let factor = Float(i) / Float(fadeFrames)
            data[i] *= factor
            data[Int(frameCount) - 1 - i] *= factor
        }
        
        return buffer
    }
}
```

### 4. View Model

```swift
// ChordPlayerViewModel.swift
import SwiftUI
import Observation

@Observable
final class ChordPlayerViewModel {
    private let audioEngine = AudioEngine()
    
    // Observable properties
    var availableChords: [Chord] = []
    var currentlyPlayingChordId: String?
    
    var isPlaying: Bool {
        audioEngine.isPlaying
    }
    
    init() {
        setupChords()
    }
    
    private func setupChords() {
        availableChords = [
            Chord.createMajorChord(root: "C"),
            Chord.createMajorChord(root: "D"),
            Chord.createMajorChord(root: "F"),
            Chord.createMajorChord(root: "G")
        ]
    }
    
    func playChord(_ chord: Chord) {
        currentlyPlayingChordId = chord.name
        audioEngine.playChord(chord)
        
        // Auto-clear playing state after duration
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if currentlyPlayingChordId == chord.name {
                currentlyPlayingChordId = nil
            }
        }
    }
    
    func stopPlayback() {
        audioEngine.stopCurrentPlayback()
        currentlyPlayingChordId = nil
    }
}
```

### 5. Views

#### Main Content View
```swift
// ContentView.swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ChordPadView()
                .navigationTitle("Simple Chord Player")
        }
    }
}
```

#### Chord Pad View
```swift
// ChordPadView.swift
import SwiftUI

struct ChordPadView: View {
    @State private var viewModel = ChordPlayerViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Tap a chord to play")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(viewModel.availableChords, id: \.name) { chord in
                    ChordButtonView(
                        chord: chord,
                        isPlaying: viewModel.currentlyPlayingChordId == chord.name,
                        action: {
                            viewModel.playChord(chord)
                        }
                    )
                }
            }
            .padding()
            
            if viewModel.isPlaying {
                Text("Playing...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .transition(.opacity)
            }
        }
        .padding()
    }
}
```

#### Chord Button View
```swift
// ChordButtonView.swift
import SwiftUI

struct ChordButtonView: View {
    let chord: Chord
    let isPlaying: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(chord.symbol)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(chord.name)
                    .font(.caption)
                
                // Show note names
                Text(chord.notes.map { $0.name }.joined(separator: " - "))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .foregroundColor(isPlaying ? .white : .primary)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isPlaying ? Color.blue : Color(.systemGray5))
                    .animation(.easeInOut(duration: 0.2), value: isPlaying)
            )
        }
        .buttonStyle(.plain)
        .disabled(isPlaying)
    }
}
```

## Key Implementation Notes

### Audio Framework Choice
- Using **AVFoundation** for initial simplicity
- Can migrate to **AudioKit** later for more sophisticated synthesis
- AVAudioEngine provides adequate functionality for basic tone generation

### Observation Framework Usage
- All ViewModels use `@Observable` macro
- Views use `@State` for ViewModel instances
- No need for `@Published` or `ObservableObject`
- Cleaner code with automatic observation

### SwiftData Preparation
- Models are marked with `@Model` for future persistence
- Relationships between Note and Chord are established
- No actual persistence implemented yet
- Easy to add save/load functionality later

### Extensibility Considerations
- Chord creation is abstracted into factory methods
- Audio engine is separate from UI logic
- Note frequency calculation is reusable
- Easy to add more chord types and qualities

## Future Feature Preparation

The architecture supports these future additions:
- **More chord types**: Minor, 7th, diminished, etc.
- **Chord progressions**: Sequence multiple chords
- **Visual feedback**: Show piano keys or staff notation
- **Recording**: Save played chords
- **Settings**: Adjust volume, instrument sounds
- **MIDI support**: Connect external keyboards

## Development Steps

1. Create new Xcode project with SwiftUI and SwiftData
2. Add model classes (Note.swift, Chord.swift)
3. Implement AudioEngine with basic tone generation
4. Create ViewModel with chord setup
5. Build UI components
6. Test audio playback and timing
7. Add polish (animations, haptic feedback)
8. Make changes and add features incrementally and in testable increments
9. Development should be iterative if possible
10. Keep performance and optimization in mind

## Testing Considerations

- Test audio engine initialization
- Verify correct frequencies for each note
- Check 3-second timing accuracy
- Test simultaneous note playback
- Verify no audio glitches or clicks
- Test on different iOS devices

## Common Issues and Solutions

### Audio not playing
- Check AVAudioSession configuration
- Ensure audio engine is started
- Verify buffer creation

### Clicking sounds
- Apply fade in/out envelopes
- Check buffer boundaries
- Use proper audio format

### Performance issues
- Limit polyphony if needed
- Pre-generate common waveforms
- Use efficient buffer sizes

This implementation provides a solid foundation that can be extended with more features while keeping the initial scope manageable and focused.
