import SwiftUI

struct ChordTheorySheet: View {
    let chord: Chord
    @Environment(\.dismiss) private var dismiss
    
    private let theoryService = MusicTheoryService.shared
    @State private var viewModel = ChordPlayerViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Chord header
                    VStack(spacing: 8) {
                        Text(chord.symbol)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(chord.name)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Scale piano visualization
                    ScalePianoView(
                        scaleNotes: theoryService.getScaleWithChordHighlights(chord: chord),
                        chord: chord
                    )
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Scale visualization
                    ScaleVisualizationView(
                        scaleNotes: theoryService.getScaleWithChordHighlights(chord: chord),
                        chord: chord
                    )
                    .padding(.horizontal)
                    
                    // Chord function (preparation for future features)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Chord Function")
                            .font(.headline)
                        
                        Text(theoryService.getChordFunction(chord: chord, inKey: chord.symbol))
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Relative minor chord
                    RelativeMinorView(
                        majorChord: chord,
                        theoryService: theoryService,
                        viewModel: viewModel
                    )
                    .padding(.horizontal)
                    
                    // Dominant chord
                    DominantChordView(
                        majorChord: chord,
                        theoryService: theoryService,
                        viewModel: viewModel
                    )
                    .padding(.horizontal)
                    
                    // Piano visualization for reference
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Piano Keys")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        PianoKeyboardView(
                            highlightedNotes: Set(chord.notes.map { $0.name }),
                            octave: 4
                        )
                        .scaleEffect(0.9)
                        .frame(height: 80)
                        .padding(.horizontal)
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