import SwiftUI

struct PianoKeyView: View {
    let note: String
    let isHighlighted: Bool
    let keyWidth: CGFloat
    
    var isBlackKey: Bool {
        note.contains("#") || note.contains("b")
    }
    
    var body: some View {
        if isBlackKey {
            blackKeyView
        } else {
            whiteKeyView
        }
    }
    
    private var whiteKeyView: some View {
        Rectangle()
            .fill(isHighlighted ? Color.blue.opacity(0.7) : Color.white)
            .frame(width: keyWidth, height: keyWidth * 4)
            .overlay(
                Rectangle()
                    .stroke(Color.black, lineWidth: 1)
            )
            .overlay(
                Text(note)
                    .font(.system(size: 10))
                    .foregroundColor(isHighlighted ? .white : .black)
                    .offset(y: keyWidth * 1.5)
            )
    }
    
    private var blackKeyView: some View {
        Rectangle()
            .fill(isHighlighted ? Color.blue : Color.black)
            .frame(width: keyWidth * 0.6, height: keyWidth * 2.5)
            .overlay(
                Text(note)
                    .font(.system(size: 8))
                    .foregroundColor(.white)
                    .offset(y: keyWidth * 0.8)
            )
    }
}