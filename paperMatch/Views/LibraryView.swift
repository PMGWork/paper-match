import SwiftUI

struct LibraryView: View {
    @ObservedObject var paperStore: PaperStore
    @ObservedObject var genreManager: GenreManager
    
    @State private var searchText = ""
    @State private var selectedSortOption = SortOption.dateAdded
    @State private var isShowingGenreSettings = false
    
    enum SortOption: String, CaseIterable {
        case dateAdded = "Date Added"
        case title = "Title"
        case author = "Author"
        case published = "Published Date"
    }
    
    var filteredAndSortedPapers: [Paper] {
        let filtered = searchText.isEmpty ? paperStore.savedPapers : 
            paperStore.savedPapers.filter { paper in
                paper.title.localizedCaseInsensitiveContains(searchText) ||
                paper.authorsString.localizedCaseInsensitiveContains(searchText) ||
                paper.categories.joined().localizedCaseInsensitiveContains(searchText)
            }
        
        return filtered.sorted { paper1, paper2 in
            switch selectedSortOption {
            case .dateAdded:
                return paper1.publishedDate > paper2.publishedDate
            case .title:
                return paper1.title < paper2.title
            case .author:
                return paper1.authorsString < paper2.authorsString
            case .published:
                return paper1.publishedDate > paper2.publishedDate
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if paperStore.savedPapers.isEmpty {
                    emptyStateView
                } else {
                    VStack(spacing: 0) {
                        // Search and Filter Bar
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                
                                TextField("Search saved papers...", text: $searchText)
                                    .textFieldStyle(PlainTextFieldStyle())
                                
                                if !searchText.isEmpty {
                                    Button("Clear") {
                                        searchText = ""
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            
                            HStack {
                                Text("Sort by:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Picker("Sort", selection: $selectedSortOption) {
                                    ForEach(SortOption.allCases, id: \.self) { option in
                                        Text(option.rawValue).tag(option)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                
                                Spacer()
                                
                                Text("\(filteredAndSortedPapers.count) papers")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        
                        // Papers List
                        List {
                            ForEach(filteredAndSortedPapers) { paper in
                                LibraryPaperRowView(paper: paper, paperStore: paperStore)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            }
                            .onDelete(perform: deletePapers)
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingGenreSettings = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingGenreSettings) {
            GenreTagsView(genreManager: genreManager, paperStore: paperStore, currentIndex: .constant(0))
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
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private func deletePapers(offsets: IndexSet) {
        for offset in offsets {
            let paper = filteredAndSortedPapers[offset]
            paperStore.removeSavedPaper(paper)
        }
    }
}

struct LibraryPaperRowView: View {
    let paper: Paper
    let paperStore: PaperStore
    
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
                ForEach(Array(paper.categories.prefix(3)), id: \.self) { category in
                    Text(category)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
                
                if paper.categories.count > 3 {
                    Text("+\(paper.categories.count - 3)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    if let pdfUrl = paper.pdfUrl {
                        Button(action: {
                            if let url = URL(string: pdfUrl) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.red)
                        }
                    }
                    
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
    LibraryView(paperStore: PaperStore(), genreManager: GenreManager())
}