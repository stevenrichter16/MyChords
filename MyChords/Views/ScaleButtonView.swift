import SwiftUI

struct ScaleButtonView: View {
    let scale: Scale
    let viewModel: ChordPlayerViewModel
    
    @State private var showingTheorySheet = false
    @AppStorage("showPianoVisualization") private var showPiano = false
    
    private var scaleNoteSet: Set<String> {
        Set(scale.notes)
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: {
                // For now, play the scale as a chord (all notes together)
                // This can be enhanced later to play notes sequentially
                let scaleChord = Chord(
                    name: scale.name,
                    symbol: scale.rootNote,
                    notes: scale.notes.map { Note(name: $0, octave: 4) }
                )
                viewModel.playChord(scaleChord)
            }) {
                VStack(spacing: 8) {
                    Text(scale.rootNote)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Major Scale")
                        .font(.caption)
                    
                    if showPiano {
                        PianoKeyboardView(
                            highlightedNotes: scaleNoteSet,
                            octave: 4
                        )
                        .scaleEffect(0.7)
                        .frame(height: 60)
                        .allowsHitTesting(false)
                    } else {
                        Text(scale.notes.joined(separator: " - "))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: showPiano ? 160 : 120)
                .padding(.vertical, showPiano ? 8 : 0)
                .foregroundColor(viewModel.currentlyPlayingChordId == scale.name ? .white : .primary)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(viewModel.currentlyPlayingChordId == scale.name ? Color.green : Color(.systemGray5))
                        .animation(.easeInOut(duration: 0.2), value: viewModel.currentlyPlayingChordId == scale.name)
                )
            }
            .buttonStyle(.plain)
            .disabled(viewModel.currentlyPlayingChordId == scale.name)
            
            // Info button
            Button(action: {
                showingTheorySheet = true
            }) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
                    .background(Circle().fill(Color.white))
                    .clipShape(Circle())
            }
            .offset(x: -8, y: 8)
        }
        .sheet(isPresented: $showingTheorySheet) {
            ScaleTheorySheet(scale: scale)
        }
    }
}
