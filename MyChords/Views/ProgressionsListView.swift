import SwiftUI

struct ProgressionsListView: View {
    @State private var viewModel = ChordPlayerViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.chordProgressions) { progression in
                    ChordProgressionView(progression: progression, viewModel: viewModel)
                }
            }
            .padding()
        }
    }
}