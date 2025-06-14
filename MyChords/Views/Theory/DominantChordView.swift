import SwiftUI

struct DominantChordView: View {
    let majorChord: Chord
    let theoryService: MusicTheoryService
    let viewModel: ChordPlayerViewModel
    
    @State private var showDominant7 = false
    
    private var dominantChord: Chord {
        theoryService.getDominant(forMajorKey: majorChord.symbol)
    }
    
    private var dominant7Chord: Chord {
        theoryService.getDominant7(forMajorKey: majorChord.symbol)
    }
    
    private var currentChord: Chord {
        showDominant7 ? dominant7Chord : dominantChord
    }
    
    private var dominantNoteSet: Set<String> {
        Set(currentChord.notes.map { $0.name })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Text("Dominant Chord")
                .font(.headline)
            
            VStack(spacing: 16) {
                // Chord type toggle
                Picker("Chord Type", selection: $showDominant7) {
                    Text("V (Dominant)").tag(false)
                    Text("V7 (Dominant 7)").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Chord info with play button
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentChord.name)
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Text(showDominant7 ? "Creates stronger resolution to tonic" : "Creates tension that resolves to tonic")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Play button
                    Button(action: {
                        viewModel.playChord(currentChord)
                    }) {
                        Image(systemName: viewModel.currentlyPlayingChordId == currentChord.name ? "speaker.wave.3.fill" : "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                    .disabled(viewModel.isPlaying)
                }
                .padding(.horizontal)
                
                // Piano visualization
                PianoKeyboardView(
                    highlightedNotes: dominantNoteSet,
                    octave: 4
                )
                .scaleEffect(0.85)
                .frame(height: 70)
                
                // Notes display
                Text(currentChord.notes.map { $0.name }.joined(separator: " - "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Music theory explanation
                VStack(alignment: .leading, spacing: 8) {
                    Text("Relationship to \(majorChord.symbol) Major:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    if showDominant7 {
                        Text("• The V7 chord adds a minor 7th interval")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("• Creates tritone tension between 3rd and 7th")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("• Strongly pulls toward the tonic (\(majorChord.symbol))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("• Essential in jazz, blues, and classical music")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } else {
                        Text("• Located at the 5th degree of the major scale")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("• Most important chord after the tonic")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("• Creates harmonic tension that wants to resolve")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("• Forms the basis of V-I cadences")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
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