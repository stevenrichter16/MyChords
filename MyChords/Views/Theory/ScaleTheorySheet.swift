import SwiftUI

struct ScaleTheorySheet: View {
    let scale: Scale
    @Environment(\.dismiss) private var dismiss
    
    private let chordTypes: [(type: ChordType, name: String)] = [
        (.major, "Major"),
        (.minor, "Minor"),
        (.major7, "Major 7"),
        (.dominant7, "Dominant 7")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Scale header
                    VStack(spacing: 8) {
                        Text(scale.rootNote)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("\(scale.name) Scale")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        // Show all scale notes
                        Text(scale.notes.joined(separator: " - "))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Chord variations
                    VStack(spacing: 20) {
                        Text("Chord Variations")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        ForEach(chordTypes, id: \.type) { chordType in
                            if let chord = scale.getChordAtDegree(1, chordType: chordType.type) {
                                ChordVariationView(
                                    chord: chord,
                                    chordType: chordType.type,
                                    chordTypeName: chordType.name,
                                    scale: scale
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ChordVariationView: View {
    let chord: Chord
    let chordType: ChordType
    let chordTypeName: String
    let scale: Scale
    
    @State private var viewModel = ChordPlayerViewModel()
    
    private var chordNoteSet: Set<String> {
        Set(chord.notes.map { $0.name })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Chord header with degree notation
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(chord.name)
                        .font(.headline)
                    
                    Text(chordType.degreeNotation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Play button
                Button(action: {
                    viewModel.playChord(chord)
                }) {
                    Image(systemName: viewModel.currentlyPlayingChordId == chord.name ? "speaker.wave.3.fill" : "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .disabled(viewModel.isPlaying && viewModel.currentlyPlayingChordId != chord.name)
            }
            
            // Piano visualization showing full octave with chord notes highlighted
            ScaleCompatiblePianoKeyboardView(
                highlightedNotes: chordNoteSet,
                rootNote: chord.symbol,
                octave: 4
            )
            .frame(height: 100)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Chord notes
            Text(chord.notes.map { $0.name }.joined(separator: " - "))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
