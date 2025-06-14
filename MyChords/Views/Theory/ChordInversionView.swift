import SwiftUI

struct ChordInversionView: View {
    let baseChord: Chord
    let viewModel: ChordPlayerViewModel
    let chordColor: Color
    
    @State private var selectedInversion = 0
    
    private var currentChord: Chord {
        if selectedInversion == 0 {
            return baseChord
        } else {
            return baseChord.inverted(inversion: selectedInversion)
        }
    }
    
    // Create note names for backward compatibility
    private var currentNoteSet: Set<String> {
        Set(currentChord.notes.map { $0.name })
    }
    
    // Create note+octave positions for accurate piano display
    private var currentNotePositions: Set<String> {
        Set(currentChord.notes.map { "\($0.name)\($0.octave)" })
    }
    
    private var inversionOptions: [Int] {
        // Generate options based on chord size (triads have 0,1,2; seventh chords have 0,1,2,3)
        Array(0..<baseChord.notes.count)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Chord header with inversion picker
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(baseChord.name)
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    if selectedInversion > 0 {
                        Text("Bass: \(currentChord.bassNote?.name ?? "")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Inversion picker
                Picker("Inversion", selection: $selectedInversion) {
                    ForEach(inversionOptions, id: \.self) { inversion in
                        Text(inversionName(for: inversion))
                            .tag(inversion)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(minWidth: 140)
            }
            
            // Play button and piano
            HStack {
                // Play button
                Button(action: {
                    viewModel.playChord(currentChord)
                }) {
                    Image(systemName: viewModel.currentlyPlayingChordId == currentChord.name ? "speaker.wave.3.fill" : "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(viewModel.isPlaying ? .purple : chordColor)
                }
                .disabled(viewModel.isPlaying)
                
                Spacer()
                
                // Note display
                Text(currentChord.notes.map { $0.name }.joined(separator: " - "))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Piano visualization with exact note positions
            PianoKeyboardView(
                highlightedNotes: currentNoteSet,
                octave: 4,
                highlightedNotePositions: currentNotePositions
            )
            .scaleEffect(0.85)
            .frame(height: 70)
            
            // Educational explanation
            if selectedInversion > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("About \(currentChord.inversionName):")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text(inversionExplanation(for: selectedInversion))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func inversionName(for inversion: Int) -> String {
        switch inversion {
        case 0: return "Root Position"
        case 1: return "1st Inversion"
        case 2: return "2nd Inversion"
        case 3: return "3rd Inversion"
        default: return "\(inversion)th Inversion"
        }
    }
    
    private func inversionExplanation(for inversion: Int) -> String {
        let bassNote = currentChord.bassNote?.name ?? ""
        let chordType = baseChord.notes.count == 3 ? "triad" : "seventh chord"
        
        switch inversion {
        case 1:
            return "• The 3rd of the chord (\(bassNote)) is now in the bass\n• Creates a smoother, less stable sound\n• Common in chord progressions for voice leading"
        case 2:
            return "• The 5th of the chord (\(bassNote)) is now in the bass\n• Often used as a passing chord\n• Creates forward motion in progressions"
        case 3:
            return "• The 7th of the chord (\(bassNote)) is now in the bass\n• Creates strong tension that wants to resolve\n• Common in jazz and classical music"
        default:
            return "• The chord tones have been rearranged\n• Changes the character while keeping the same harmony"
        }
    }
}