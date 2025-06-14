import SwiftUI

struct ScalesView: View {
    @State private var viewModel = ChordPlayerViewModel()
    
    private let availableScales: [Scale] = [
        Scale.createMajorScale(root: "A"),
        Scale.createMajorScale(root: "B"),
        Scale.createMajorScale(root: "C"),
        Scale.createMajorScale(root: "D"),
        Scale.createMajorScale(root: "E"),
        Scale.createMajorScale(root: "F"),
        Scale.createMajorScale(root: "G")
    ]
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Major Scales")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.top)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(availableScales, id: \.name) { scale in
                        ScaleButtonView(
                            scale: scale,
                            viewModel: viewModel
                        )
                    }
                }
                .padding()
            }
        }
    }
}