import SwiftUI

struct DominantChordView: View {
    let majorChord: Chord
    let theoryService: MusicTheoryService
    let viewModel: ChordPlayerViewModel
    
    @State private var showDominant7 = false
    @State private var selectedInversion = 0
    
    private var baseDominantChord: Chord {
        theoryService.getDominant(forMajorKey: majorChord.symbol)
    }
    
    private var baseDominant7Chord: Chord {
        theoryService.getDominant7(forMajorKey: majorChord.symbol)
    }
    
    private var baseChord: Chord {
        showDominant7 ? baseDominant7Chord : baseDominantChord
    }
    
    private var currentChord: Chord {
        if selectedInversion == 0 {
            return baseChord
        } else {
            return baseChord.inverted(inversion: selectedInversion)
        }
    }
    
    private var dominantNoteSet: Set<String> {
        Set(currentChord.notes.map { $0.name })
    }
    
    private var currentNotePositions: Set<String> {
        Set(currentChord.notes.map { "\($0.name)\($0.octave)" })
    }
    
    private var inversionOptions: Int {
        // Dominant 7 has 4 inversions, regular dominant has 3
        showDominant7 ? 4 : 3
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
                .onChange(of: showDominant7) { oldValue, newValue in
                    // Reset inversion when switching chord types if it's out of bounds
                    if selectedInversion >= inversionOptions {
                        selectedInversion = 0
                    }
                }
                
                // Chord info with play button
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(baseChord.name)
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
                
                // Inversion picker
                HStack {
                    Text("Inversion:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Inversion", selection: $selectedInversion) {
                        Text("Root").tag(0)
                        Text("1st").tag(1)
                        Text("2nd").tag(2)
                        if showDominant7 {
                            Text("3rd").tag(3)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal)
                
                // Piano visualization
                PianoKeyboardView(
                    highlightedNotes: dominantNoteSet,
                    octave: 4,
                    highlightedNotePositions: currentNotePositions
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