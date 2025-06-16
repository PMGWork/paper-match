import SwiftUI

struct GenreSettingsView: View {
    @ObservedObject var genreManager: GenreManager
    @ObservedObject var paperStore: PaperStore
    @Binding var currentIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    @State private var isShowingAddGenre = false
    @State private var newGenreName = ""
    @State private var newGenreQuery = ""
    @State private var showingQueryHelp = false
    
    init(genreManager: GenreManager, paperStore: PaperStore, currentIndex: Binding<Int>? = nil) {
        self.genreManager = genreManager
        self.paperStore = paperStore
        self._currentIndex = currentIndex ?? .constant(0)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(genreManager.genres) { genre in
                        GenreRowView(
                            genre: genre,
                            genreManager: genreManager,
                            onToggle: {
                                genreManager.toggleGenre(genre)
                            },
                            onDelete: genre.isDefault ? nil : {
                                genreManager.removeGenre(genre)
                            }
                        )
                    }
                } header: {
                    HStack {
                        Text("Available Genres")
                        Spacer()
                        Text("\(genreManager.enabledGenres.count) enabled")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } footer: {
                    Text("Enable the genres you're interested in. Papers will be selected from enabled genres.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button {
                        isShowingAddGenre = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                            Text("Add Custom Genre")
                        }
                    }
                } header: {
                    Text("Custom Genres")
                } footer: {
                    Button("Query Help") {
                        showingQueryHelp = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Genre Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Apply") {
                        applyChanges()
                    }
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingAddGenre) {
            AddGenreView(
                genreName: $newGenreName,
                genreQuery: $newGenreQuery,
                onSave: {
                    genreManager.addCustomGenre(name: newGenreName, query: newGenreQuery)
                    newGenreName = ""
                    newGenreQuery = ""
                }
            )
        }
        .alert("Query Help", isPresented: $showingQueryHelp) {
            Button("OK") { }
        } message: {
            Text("""
            Examples:
            • cat:cs.AI (AI papers)
            • cat:cs.LG (Machine Learning)
            • cat:cs.CV (Computer Vision)
            • all:transformer (papers with "transformer")
            • ti:quantum (title contains "quantum")
            • au:smith (author contains "smith")
            
            Use OR to combine: cat:cs.AI OR cat:cs.LG
            """)
        }
    }
    
    private func applyChanges() {
        currentIndex = 0
        let query = genreManager.getRandomQuery()
        paperStore.searchPapers(query: query)
        dismiss()
    }
}

struct GenreRowView: View {
    let genre: Genre
    let genreManager: GenreManager
    let onToggle: () -> Void
    let onDelete: (() -> Void)?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(genre.name)
                        .font(.headline)
                    
                    if genre.isDefault {
                        Text("Default")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
                
                Text(genre.query)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { genre.isEnabled },
                set: { _ in onToggle() }
            ))
        }
        .swipeActions(edge: .trailing) {
            if let onDelete = onDelete {
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            }
        }
    }
}

struct AddGenreView: View {
    @Binding var genreName: String
    @Binding var genreQuery: String
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingPreview = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Genre Name", text: $genreName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Search Query", text: $genreQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } header: {
                    Text("New Genre")
                } footer: {
                    Text("Enter a name and ArXiv search query for your custom genre.")
                }
                
                Section {
                    Button("Quick Templates") {
                        // You can add preset templates here
                    }
                } header: {
                    Text("Templates")
                } footer: {
                    Text("Common query patterns:\n• cat:cs.XX for categories\n• all:keyword for any field\n• ti:keyword for titles only")
                }
            }
            .navigationTitle("Add Genre")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .disabled(genreName.isEmpty || genreQuery.isEmpty)
                }
            }
        }
    }
}

#Preview {
    GenreSettingsView(genreManager: GenreManager(), paperStore: PaperStore())
}