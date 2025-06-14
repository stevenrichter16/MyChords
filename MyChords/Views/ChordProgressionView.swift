import SwiftUI

struct ChordProgressionView: View {
    let progression: ChordProgression
    let viewModel: ChordPlayerViewModel
    
    var isPlayingProgression: Bool {
        viewModel.currentlyPlayingProgressionId == progression.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(progression.name)
                        .font(.headline)
                    
                    Text(progression.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    if isPlayingProgression {
                        viewModel.stopPlayback()
                    } else {
                        viewModel.playProgression(progression)
                    }
                }) {
                    Image(systemName: isPlayingProgression ? "stop.fill" : "play.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(isPlayingProgression ? Color.red : Color.green))
                }
                .buttonStyle(.plain)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(progression.chords.enumerated()), id: \.offset) { index, chord in
                        VStack(spacing: 4) {
                            Button(action: {
                                viewModel.playChord(chord)
                            }) {
                                VStack(spacing: 4) {
                                    Text(chord.symbol)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Text(chord.notes.map { $0.name }.joined(separator: "-"))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(width: 80, height: 80)
                                .foregroundColor(isPlayingProgression && viewModel.currentlyPlayingProgressionIndex == index ? .white : .primary)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(isPlayingProgression && viewModel.currentlyPlayingProgressionIndex == index ? Color.blue : Color(.systemGray5))
                                        .animation(.easeInOut(duration: 0.2), value: isPlayingProgression && viewModel.currentlyPlayingProgressionIndex == index)
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(isPlayingProgression)
                            
                            if index < progression.chords.count - 1 {
                                Image(systemName: "arrow.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}