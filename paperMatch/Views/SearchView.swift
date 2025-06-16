import SwiftUI

struct SearchView: View {
    @ObservedObject var paperStore: PaperStore
    @ObservedObject var genreManager: GenreManager
    @Binding var currentIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var selectedGenre: Genre?
    @State private var searchType = SearchType.keyword
    
    enum SearchType: String, CaseIterable {
        case keyword = "Keyword"
        case genre = "Genre"
        case custom = "Custom Query"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Search Papers")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Picker("Search Type", selection: $searchType) {
                        ForEach(SearchType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    switch searchType {
                    case .keyword:
                        keywordSearchView
                    case .genre:
                        genreSearchView
                    case .custom:
                        customQueryView
                    }
                }
                .padding()
                
                Button("Search") {
                    performSearch()
                }
                .buttonStyle(.borderedProminent)
                .disabled(paperStore.isLoading || !canSearch)
                
                if paperStore.isLoading {
                    ProgressView("Searching...")
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Search")
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
    
    private var keywordSearchView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Keywords")
                .font(.headline)
            
            TextField("Enter keywords (e.g., transformer, quantum, neural)", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("Search across all paper fields including title, abstract, and content.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var genreSearchView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Genre")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(genreManager.genres) { genre in
                        GenreButton(
                            genre: genre,
                            isSelected: selectedGenre?.id == genre.id
                        ) {
                            selectedGenre = genre
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            if let selectedGenre = selectedGenre {
                Text("Query: \(selectedGenre.query)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
    }
    
    private var customQueryView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Custom ArXiv Query")
                .font(.headline)
            
            TextField("Enter ArXiv query (e.g., cat:cs.AI OR ti:quantum)", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("Use ArXiv query syntax. Examples:\n• cat:cs.AI (AI category)\n• ti:quantum (title contains quantum)\n• au:smith (author contains smith)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var canSearch: Bool {
        switch searchType {
        case .keyword, .custom:
            return !searchText.isEmpty
        case .genre:
            return selectedGenre != nil
        }
    }
    
    private func performSearch() {
        let query: String
        
        switch searchType {
        case .keyword:
            query = "all:\(searchText)"
        case .genre:
            query = selectedGenre?.query ?? genreManager.getRandomQuery()
        case .custom:
            query = searchText
        }
        
        currentIndex = 0
        paperStore.searchPapers(query: query)
        dismiss()
    }
}

struct GenreButton: View {
    let genre: Genre
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(genre.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                
                if !genre.isEnabled {
                    Text("Disabled")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : (genre.isEnabled ? Color(.systemGray5) : Color(.systemGray6)))
            .foregroundColor(isSelected ? .white : (genre.isEnabled ? .primary : .secondary))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: isSelected ? 2 : 0)
            )
        }
        .disabled(!genre.isEnabled)
    }
}

#Preview {
    SearchView(paperStore: PaperStore(), genreManager: GenreManager(), currentIndex: .constant(0))
}