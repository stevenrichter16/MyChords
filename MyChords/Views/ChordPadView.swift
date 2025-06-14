import SwiftUI

struct ChordPadView: View {
    @State private var viewModel = ChordPlayerViewModel()
    @State private var showPianoVisualization = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Tap a chord to play")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Toggle("Piano", isOn: $showPianoVisualization)
                        .toggleStyle(.button)
                        .font(.caption)
                }
                .padding(.horizontal)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(viewModel.availableChords, id: \.name) { chord in
                        ChordButtonWithPianoView(
                            chord: chord,
                            isPlaying: viewModel.currentlyPlayingChordId == chord.name,
                            showPiano: showPianoVisualization,
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
            .padding(.vertical)
        }
    }
}