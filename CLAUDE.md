# CLAUDE.md - MyChords iOS App

## Project Overview

MyChords is an educational iOS chord player app built with SwiftUI and the Observation framework. The app helps users learn music theory through interactive chord playback, visual piano representations, and detailed scale relationships. It started as a simple 4-chord player and has evolved into a comprehensive music theory learning tool.

## Core Features

- **Triple-tab interface**: Chords tab, Scales tab, and Progressions tab
- **7 Major chords**: C, D, E, F, G, A, B with synthesized playback
- **7 Major scales**: A, B, C, D, E, F, G for scale exploration
- **Chord progressions**: 10 popular progressions with sequential playback
- **Piano visualizations**: Toggle between text and piano key display
- **Music theory education**: Scale relationships, chord construction, degree analysis
- **Interactive theory sheets**: Detailed information for each chord including:
  - Scale degree visualization
  - Relative minor chord with playback
  - Dominant and Dominant 7 chords with playback
  - Educational explanations of chord relationships
- **Object-oriented design** with models, services, and view models
- **Observation framework** for state management
- **Modular, extensible architecture** ready for additional features

## Current Project Structure

```
MyChords/
├── Models/
│   ├── Note.swift              # Note with frequency calculation
│   ├── Chord.swift             # Chord with factory methods
│   ├── ScaleNote.swift         # Scale degree information
│   ├── ChordProgression.swift  # Progression sequences
│   └── Scale.swift             # Scale model with chord generation
├── Views/
│   ├── ContentView.swift       # Tab-based navigation (3 tabs)
│   ├── ChordButtonView.swift   # Original chord button
│   ├── ChordButtonWithPianoView.swift # Enhanced with info
│   ├── ChordPadView.swift      # Grid of chords
│   ├── ScalesView.swift        # Grid of scale buttons
│   ├── ScaleButtonView.swift   # Scale button with info icon
│   ├── ProgressionsListView.swift # Progression list
│   ├── ChordProgressionView.swift # Single progression UI
│   ├── Piano/
│   │   ├── PianoKeyView.swift  # Individual piano key
│   │   └── PianoKeyboardView.swift # Full keyboard
│   └── Theory/
│       ├── ChordTheorySheet.swift # Theory modal with chord relationships
│       ├── ScaleTheorySheet.swift # Scale theory with chord variations
│       ├── RelativeMinorView.swift # Relative minor display
│       ├── DominantChordView.swift # Dominant chord display
│       ├── ScaleVisualizationView.swift # Scale degrees
│       ├── ScalePianoView.swift # Scale on piano with dual views
│       └── ScaleCompatiblePianoView.swift # Piano for sharp/flat notes
├── ViewModels/
│   └── ChordPlayerViewModel.swift # State management
├── Services/
│   └── MusicTheoryService.swift # Theory calculations + chord relationships
├── Audio/
│   └── AudioEngine.swift       # Sound synthesis with proper state management
└── MyChordsApp.swift          # App entry point
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

### Planned Chord Relationships for ChordTheorySheet

The following chord relationships should be displayed for each major chord to enhance music theory education:

#### 1. **Diatonic Chords** (Built from the major scale)
- **ii** - Supertonic minor (2nd degree)
- **iii** - Mediant minor (3rd degree)
- **IV** - Subdominant major (4th degree)
- **V** - Dominant major (5th degree)
- **vi** - Relative minor (6th degree) ✓ Already implemented
- **vii°** - Leading tone diminished (7th degree)

#### 2. **Essential Functional Chords**
- **Subdominant (IV)** - Creates movement away from tonic
- **Dominant (V)** - Creates tension that resolves to I
- **Dominant 7th (V7)** - Stronger resolution with added 7th

#### 3. **Modal Interchange Chords** (Borrowed from parallel minor)
- **iv** - Minor subdominant (e.g., Fm in C major)
- **bVI** - Flat six major (e.g., Ab in C major)
- **bVII** - Flat seven major (e.g., Bb in C major)
- **ii°** - Diminished two

#### 4. **Secondary Dominants**
- **V/V** - Dominant of the dominant (e.g., D major in C)
- **V/IV** - Dominant of the subdominant
- **V/vi** - Dominant of the relative minor

#### 5. **Common Chord Extensions**
- **maj7** - Major 7th (jazzy sound)
- **7** - Dominant 7th (bluesy sound)
- **sus2** - Suspended 2nd (ethereal sound)
- **sus4** - Suspended 4th (tension/release)
- **add9** - Added 9th (color tone)
- **6** - Major 6th (vintage sound)

#### 6. **Parallel and Chromatic Relationships**
- **Parallel minor** - Same root, minor quality (C major → C minor)
- **Chromatic mediant** - Major/minor thirds away (C → E, C → Ab, C → A, C → Eb)
- **Neapolitan** - bII major (classical sound)

### Implementation Priority

For the best educational progression, implement in this order:
1. **Relative minor (vi)** - ✓ Complete
2. **Dominant (V) and Dominant 7th (V7)** - Essential for understanding resolution
3. **Subdominant (IV)** - Completes the I-IV-V progression
4. **Parallel minor** - Shows major/minor contrast
5. **All diatonic chords (ii, iii, vii°)** - Complete scale harmonization
6. **Modal interchange (iv, bVI, bVII)** - Introduces borrowed chords
7. **Extensions (maj7, sus, add9)** - Advanced harmony

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

## Architectural Patterns & Development Philosophy

### Modular Component Design

Throughout development, we've established key patterns for building reusable, extensible components:

#### 1. **Separation of Concerns**
- **Models** (`Note`, `Chord`, `ScaleNote`, `ChordProgression`): Pure data structures with minimal logic
- **Services** (`MusicTheoryService`): Business logic and calculations separated from UI
- **Views**: Focused on presentation, broken into small, reusable components
- **ViewModels**: State management using Observation framework, bridging models and views

#### 2. **Component Hierarchy**

```
ChordButtonView (original)
    ↓
ChordButtonWithPianoView (enhanced with piano viz)
    ├── PianoKeyboardView (reusable piano component)
    │   └── PianoKeyView (individual key)
    └── ChordTheorySheet (modal for theory info)
        ├── ScalePianoView (scale-specific piano)
        │   └── ScalePianoKeyboardView (dynamic layout)
        └── ScaleVisualizationView (degree analysis)
```

Each component is designed to be:
- **Self-contained**: Can function independently
- **Configurable**: Accepts parameters for different use cases
- **Composable**: Can be combined to create complex features

#### 3. **Progressive Enhancement Pattern**

We followed a pattern of iterative enhancement:
1. Start with basic functionality (4 chord buttons)
2. Add features without breaking existing code
3. Create enhanced versions rather than modifying originals
4. Use composition to add capabilities

Example: `ChordButtonView` → `ChordButtonWithPianoView` (added piano viz and info button)

### Key Design Decisions

#### 1. **Visual Components as Separate Views**
- `PianoKeyboardView`: Generic piano that can highlight any set of notes
- `ScalePianoView`: Specialized for showing scales with chord highlights
- `ScaleVisualizationView`: Focuses on music theory relationships

This separation allows:
- Reuse in different contexts
- Easy testing of individual components
- Clear responsibility boundaries

#### 2. **Service Layer for Business Logic**
```swift
MusicTheoryService.shared
├── getMajorScale(root:)
├── getScaleWithChordHighlights(chord:)
└── getChordFunction(chord:, inKey:)
```

Benefits:
- Centralized music theory calculations
- Testable pure functions
- Easy to extend with new theory concepts

#### 3. **Dynamic UI Generation**
Instead of hardcoding UI layouts, we generate them based on data:
- Piano keys positioned dynamically based on root note
- Chord buttons generated from chord array
- Scale visualizations built from scale data

### Development Best Practices Established

#### 1. **Incremental Development**
- Start with minimal viable feature
- Test thoroughly before adding complexity
- Each feature should work standalone
- Use todo lists to track incremental progress

#### 2. **User Feedback Integration**
- Fixed audio buzzing by reducing amplitude and adding harmonics
- Removed confusing connection lines in favor of clear pattern visualization
- Adjusted piano visualization to start from tonic note
- Added octave indication for educational clarity

#### 3. **Educational Focus**
Every feature enhancement considered educational value:
- Piano visualization shows which keys to press
- Scale visualization explains chord construction
- Theory sheets provide multiple perspectives
- Visual hierarchy guides learning (colors, sizing, labels)

### Future-Proofing Strategies

#### 1. **Extensible Models**
```swift
// Current: Major chords only
Chord.createMajorChord(root: "C")

// Future: Easy to add
Chord.createMinorChord(root: "C")
Chord.createSeventhChord(root: "C")
Chord.createDiminishedChord(root: "C")
```

#### 2. **Pluggable Visualizations**
The sheet-based architecture allows adding new theory views:
- Chord inversions view
- Circle of fifths integration
- Staff notation display
- Interval training games

#### 3. **State Management Ready for Complexity**
Using Observation framework positions the app for:
- Multi-chord selection
- Progression building
- Recording and playback
- User preferences

### Code Quality Principles

#### 1. **Clear Naming Conventions**
- `isPlaying`, `isInScale`, `isInChord`: Boolean states are clearly named
- `ScalePianoView` vs `PianoKeyboardView`: Purpose is evident from naming
- Services, Models, Views organized in appropriate folders

#### 2. **Computed Properties for Derived State**
```swift
var isPlayingProgression: Bool {
    viewModel.currentlyPlayingProgressionId == progression.id
}
```

#### 3. **SwiftUI Best Practices**
- `@State` for local view state
- `@Observable` for ViewModels
- `.sheet()` for modal presentations
- Proper view modifiers chaining

### Performance Considerations

#### 1. **Efficient Audio Generation**
- Pre-calculate buffer sizes
- Reuse player nodes
- Apply fades to prevent clicks
- Proper audio session configuration

#### 2. **UI Optimization**
- `LazyVGrid` for chord grid
- Conditional rendering (piano on/off)
- Proper `zIndex` for overlay elements
- Animation only where meaningful

### Testing & Debugging Approach

#### 1. **Visual Testing First**
- Build UI components independently
- Test with different data sets
- Verify layout at different sizes

#### 2. **Audio Testing Strategy**
- Test single notes before chords
- Verify timing accuracy
- Check for audio artifacts
- Test interruption handling

#### 3. **User Flow Testing**
- Can users discover features?
- Is the educational value clear?
- Do animations enhance understanding?
- Is the app responsive during audio playback?

### Lessons Learned

1. **Start Simple, Enhance Gradually**: The 4-chord prototype evolved into a full teaching tool
2. **User Feedback is Gold**: Every reported issue led to a better solution
3. **Modularity Pays Off**: Reusable components made feature addition smooth
4. **Education Requires Clarity**: Visual hierarchy and clear labeling are crucial
5. **Performance Matters**: Audio glitches break the experience immediately

This architectural foundation supports the app's evolution from a simple chord player to a comprehensive music theory education platform.

## Recent Development Session (December 2024)

### Major Additions

#### 1. **Scales Tab Implementation**
- Added a new Scales tab to the app's navigation
- Created Scale model with extensible design for future scale types (minor, modes, etc.)
- Implemented scale buttons for A, B, C, D, E, F, G major scales
- Built ScaleTheorySheet to show chord variations within each scale

**Status**: The ScaleTheorySheet UI has rendering issues with the piano keyboard display. Taking a break from this implementation to focus on enhancing ChordTheorySheet where the UI logic is proven to work correctly.

#### 2. **Enhanced ChordTheorySheet**
- **Relative Minor Integration**: Added RelativeMinorView showing the vi chord with:
  - Interactive playback
  - Piano visualization
  - Educational explanation of the relationship
- **Dominant Chord Integration**: Added DominantChordView featuring:
  - Toggle between V and V7 chords
  - Color-coded play buttons (orange for dominant)
  - Detailed music theory explanations
  - Piano visualization for each variation

#### 3. **MusicTheoryService Enhancements**
- Added `getRelativeMinor()` method to find the 6th degree minor chord
- Added `getDominant()` and `getDominant7()` methods for dominant relationships
- Maintained clean separation of music theory logic from UI

### Technical Improvements

#### 1. **Audio Engine State Management Fix**
- Fixed critical bug where `isPlaying` state wasn't properly synchronized
- Implemented proper completion tracking for audio buffers
- Ensured play buttons re-enable after chord playback completes
- Solution: Track completed buffers and only set `isPlaying = false` when all finish

#### 2. **ScalePianoView Enhancement**
- Modified to display two separate piano keyboards:
  - Top: Shows only chord notes
  - Bottom: Shows all scale notes in one color
- Increased key size for better visibility
- Improved labeling and visual hierarchy

#### 3. **Sharp/Flat Note Support**
- Created ScaleCompatiblePianoView to handle enharmonic equivalents
- Implemented noteToChromatic conversion for proper key mapping
- Attempted to support proper key signatures (C, G, D, A, E, B, F#, F, Bb, Eb, Ab, Db, Gb)

### Architecture Decisions

#### 1. **Shared ViewModel Pattern**
- ChordTheorySheet creates single ChordPlayerViewModel instance
- Passes it to child views (RelativeMinorView, DominantChordView)
- Prevents state management issues from multiple ViewModel instances

#### 2. **Component Reusability**
- Used existing PianoKeyboardView for new chord displays
- Maintained consistent visual language across features
- Leveraged proven UI components rather than creating new ones

### Known Issues & Future Direction

#### 1. **ScaleTheorySheet Piano Display**
- Piano keyboards only show 1-2 keys instead of full octave
- Root cause: Complex interaction between Scale model's note generation and piano rendering
- Decision: Focus on enhancing ChordTheorySheet where infrastructure works correctly

#### 2. **Future Development Strategy**
- All new chord relationship features will be added to ChordTheorySheet
- This leverages working UI components and proven chord generation
- Scale tab remains functional but ScaleTheorySheet needs redesign

### Lessons from This Session

1. **Reuse Working Components**: The ChordTheorySheet's approach works well - build on it
2. **State Management Matters**: Proper Observable pattern usage prevents subtle bugs
3. **Incremental Enhancement**: Adding features to working views is more reliable than creating new complex views
4. **Sharp/Flat Complexity**: Proper enharmonic handling requires careful design throughout the stack
