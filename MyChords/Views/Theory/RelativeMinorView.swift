import SwiftUI

struct RelativeMinorView: View {
    let majorChord: Chord
    let theoryService: MusicTheoryService
    let viewModel: ChordPlayerViewModel
    
    @State private var selectedInversion = 0
    
    private var baseRelativeMinorChord: Chord {
        theoryService.getRelativeMinor(forMajorKey: majorChord.symbol)
    }
    
    private var currentChord: Chord {
        if selectedInversion == 0 {
            return baseRelativeMinorChord
        } else {
            return baseRelativeMinorChord.inverted(inversion: selectedInversion)
        }
    }
    
    private var relativeMinorNoteSet: Set<String> {
        Set(currentChord.notes.map { $0.name })
    }
    
    private var currentNotePositions: Set<String> {
        Set(currentChord.notes.map { "\($0.name)\($0.octave)" })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Text("Relative Minor")
                .font(.headline)
            
            VStack(spacing: 16) {
                // Chord info with play button and inversion picker
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(baseRelativeMinorChord.name)
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Text("The relative minor shares the same key signature")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Inversion picker
                    Picker("Inversion", selection: $selectedInversion) {
                        Text("Root").tag(0)
                        Text("1st").tag(1)
                        Text("2nd").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 150)
                    
                    // Play button
                    Button(action: {
                        viewModel.playChord(currentChord)
                    }) {
                        Image(systemName: viewModel.currentlyPlayingChordId == currentChord.name ? "speaker.wave.3.fill" : "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(.purple)
                    }
                    .disabled(viewModel.isPlaying)
                }
                
                // Piano visualization
                PianoKeyboardView(
                    highlightedNotes: relativeMinorNoteSet,
                    octave: 4,
                    highlightedNotePositions: currentNotePositions
                )
                .scaleEffect(0.85)
                .frame(height: 70)
                
                // Notes display
                Text(currentChord.notes.map { $0.name }.joined(separator: " - "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Relationship explanation
                VStack(alignment: .leading, spacing: 8) {
                    Text("Relationship to \(majorChord.symbol) Major:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text("• Located at the 6th degree of the major scale")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("• Contains the same notes as \(majorChord.symbol) major scale")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("• Creates a different tonal center (minor sound)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(8)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}
