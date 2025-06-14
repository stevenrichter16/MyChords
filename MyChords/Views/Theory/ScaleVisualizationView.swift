import SwiftUI

struct ScaleVisualizationView: View {
    let scaleNotes: [ScaleNote]
    let chord: Chord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("\(chord.symbol) Major Scale")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Notes in \(chord.name) are highlighted")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Scale visualization
            VStack(spacing: 16) {
                // Scale degrees and notes
                HStack(spacing: 0) {
                    ForEach(scaleNotes) { scaleNote in
                        VStack(spacing: 8) {
                            // Degree number
                            Text("\(scaleNote.degree)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(scaleNote.isInChord ? .white : .secondary)
                            
                            // Note circle
                            ZStack {
                                Circle()
                                    .fill(scaleNote.isInChord ? Color.blue : Color(.systemGray5))
                                    .frame(width: 44, height: 44)
                                
                                Text(scaleNote.note)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(scaleNote.isInChord ? .white : .primary)
                            }
                            
                            // Interval name
                            Text(scaleNote.interval)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(width: 50)
                                .lineLimit(2)
                            
                            // Degree name
                            Text(scaleNote.degreeName)
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(width: 50)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
            }
            
            // Chord formula and intervals
            VStack(alignment: .leading, spacing: 12) {
                Text("Chord Construction")
                    .font(.headline)
                
                // Formula
                HStack {
                    Text("Formula:")
                        .foregroundColor(.secondary)
                    ForEach(scaleNotes.filter { $0.isInChord }) { note in
                        HStack(spacing: 4) {
                            Text("\(note.degree)")
                                .fontWeight(.bold)
                            Text("(\(note.note))")
                                .foregroundColor(.secondary)
                        }
                        
                        if note.id != scaleNotes.filter({ $0.isInChord }).last?.id {
                            Text("-")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .font(.system(.body, design: .monospaced))
                
                // Pattern explanation
                Text("Pattern: Take the 1st, 3rd, and 5th notes of the \(chord.symbol) major scale")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Skip pattern visualization
                HStack(spacing: 2) {
                    ForEach(Array(scaleNotes.enumerated()), id: \.offset) { index, note in
                        VStack(spacing: 4) {
                            Text("\(note.degree)")
                                .font(.caption2)
                                .fontWeight(note.isInChord ? .bold : .regular)
                                .foregroundColor(note.isInChord ? .blue : .secondary)
                            
                            Rectangle()
                                .fill(note.isInChord ? Color.blue : Color(.systemGray5))
                                .frame(width: 30, height: 4)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}