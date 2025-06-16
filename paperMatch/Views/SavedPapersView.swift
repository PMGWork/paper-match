import SwiftUI

struct SavedPapersView: View {
    @ObservedObject var paperStore: PaperStore
    @Environment(\.dismiss) private var dismiss
    
    var savedPapers: [Paper] {
        paperStore.savedPapers
    }
    
    var body: some View {
        NavigationView {
            Group {
                if savedPapers.isEmpty {
                    emptyStateView
                } else {
                    papersList
                }
            }
            .navigationTitle("Saved Papers")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Saved Papers")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Papers you like will appear here")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    
    private var papersList: some View {
        List {
            ForEach(savedPapers) { paper in
                PaperRowView(paper: paper, paperStore: paperStore)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .onDelete(perform: deletePapers)
        }
        .listStyle(PlainListStyle())
    }
    
    private func deletePapers(offsets: IndexSet) {
        for offset in offsets {
            let paper = savedPapers[offset]
            paperStore.removeSavedPaper(paper)
        }
    }
}

struct PaperRowView: View {
    @State var paper: Paper
    let paperStore: PaperStore
    @State private var showTranslation = false
    @State private var isTranslating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(paper.source.rawValue)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(sourceColor)
                    .cornerRadius(4)
                
                Spacer()
                
                Text(paper.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(paper.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(paper.authorsString)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Text(paper.abstract)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                ForEach(Array(paper.categories.prefix(2)), id: \.self) { category in
                    Text(category)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
                
                if paper.categories.count > 2 {
                    Text("+\(paper.categories.count - 2)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    if let url = URL(string: paper.url) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Image(systemName: "arrow.up.right.square")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var sourceColor: Color {
        switch paper.source {
        case .arxiv:
            return .red
        case .acm:
            return .blue
        case .ieee:
            return .green
        case .other:
            return .gray
        }
    }
}

#Preview {
    SavedPapersView(paperStore: PaperStore())
}