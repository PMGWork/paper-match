import SwiftUI

struct GenreTagsView: View {
    @ObservedObject var genreManager: GenreManager
    @ObservedObject var paperStore: PaperStore
    @Binding var currentIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    @State private var isShowingAddGenre = false
    @State private var newGenreName = ""
    @State private var newGenreQuery = ""
    @State private var searchText = ""
    
    private var filteredGenres: [Genre] {
        if searchText.isEmpty {
            return genreManager.genres
        } else {
            return genreManager.genres.filter { genre in
                genre.name.localizedCaseInsensitiveContains(searchText) ||
                genre.query.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search genres...", text: $searchText)
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
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Stats Bar
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Active Genres")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(genreManager.enabledGenres.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Total Available")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(genreManager.genres.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                // Genre Tags Grid with Fixed Apply Button
                ZStack(alignment: .bottom) {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 120, maximum: 200))
                        ], spacing: 12) {
                            ForEach(filteredGenres) { genre in
                                GenreTagButton(
                                    genre: genre,
                                    onToggle: {
                                        withAnimation(.spring(response: 0.3)) {
                                            genreManager.toggleGenre(genre)
                                        }
                                    },
                                    onDelete: genre.isDefault ? nil : {
                                        withAnimation(.easeOut) {
                                            genreManager.removeGenre(genre)
                                        }
                                    }
                                )
                            }
                            
                            // Add New Genre Button
                            Button {
                                isShowingAddGenre = true
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                    
                                    Text("Add Genre")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color.green.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 80) // Space for fixed button
                    }
                    
                    // Fixed Apply Button at Bottom
                    VStack {
                        // Gradient overlay to indicate more content above
                        LinearGradient(
                            colors: [Color.clear, Color(.systemBackground).opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 20)
                        
                        Button {
                            applyChanges()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Apply Changes")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .disabled(genreManager.enabledGenres.isEmpty)
                    }
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("Select Genres")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingAddGenre) {
            AddGenreSheetView(
                genreName: $newGenreName,
                genreQuery: $newGenreQuery,
                onSave: {
                    genreManager.addCustomGenre(name: newGenreName, query: newGenreQuery)
                    newGenreName = ""
                    newGenreQuery = ""
                }
            )
        }
    }
    
    private func applyChanges() {
        currentIndex = 0
        let query = genreManager.getRandomQuery()
        paperStore.searchPapers(query: query)
        dismiss()
    }
}

struct GenreTagButton: View {
    let genre: Genre
    let onToggle: () -> Void
    let onDelete: (() -> Void)?
    
    @State private var isPressed = false
    
    var body: some View {
        Button {
            onToggle()
        } label: {
            VStack(spacing: 8) {
                HStack {
                    if genre.isDefault {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    if let onDelete = onDelete {
                        Button {
                            onDelete()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Text(genre.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Status Indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(genre.isEnabled ? Color.green : Color.gray)
                        .frame(width: 6, height: 6)
                    
                    Text(genre.isEnabled ? "Active" : "Inactive")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: genre.isEnabled ? 2 : 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: {}
        )
    }
    
    private var backgroundColor: Color {
        if genre.isEnabled {
            return Color.blue.opacity(0.1)
        } else {
            return Color(.systemGray6)
        }
    }
    
    private var borderColor: Color {
        if genre.isEnabled {
            return Color.blue
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}

struct AddGenreSheetView: View {
    @Binding var genreName: String
    @Binding var genreQuery: String
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTemplate: QueryTemplate?
    
    private let queryTemplates: [QueryTemplate] = [
        QueryTemplate(name: "AI & Machine Learning", query: "cat:cs.AI OR cat:cs.LG"),
        QueryTemplate(name: "Computer Vision", query: "cat:cs.CV"),
        QueryTemplate(name: "Natural Language", query: "cat:cs.CL"),
        QueryTemplate(name: "Robotics", query: "cat:cs.RO"),
        QueryTemplate(name: "Blockchain", query: "all:blockchain OR all:cryptocurrency"),
        QueryTemplate(name: "Quantum Computing", query: "all:quantum"),
        QueryTemplate(name: "Bioinformatics", query: "cat:q-bio"),
        QueryTemplate(name: "Physics", query: "cat:physics")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Genre Name", text: $genreName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("ArXiv Query", text: $genreQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } header: {
                    Text("Create New Genre")
                } footer: {
                    Text("Enter a name and ArXiv search query for your custom genre.")
                }
                
                Section {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 150))
                    ], spacing: 8) {
                        ForEach(queryTemplates, id: \.name) { template in
                            Button {
                                genreName = template.name
                                genreQuery = template.query
                                selectedTemplate = template
                            } label: {
                                VStack(spacing: 4) {
                                    Text(template.name)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .multilineTextAlignment(.center)
                                    
                                    Text(template.query)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(
                                    selectedTemplate?.name == template.name ? 
                                    Color.blue.opacity(0.1) : Color(.systemGray6)
                                )
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            selectedTemplate?.name == template.name ? 
                                            Color.blue : Color.clear, 
                                            lineWidth: 1
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                } header: {
                    Text("Quick Templates")
                } footer: {
                    Text("Tap a template to use it as a starting point, or create your own query.")
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

struct QueryTemplate {
    let name: String
    let query: String
}

#Preview {
    GenreTagsView(
        genreManager: GenreManager(),
        paperStore: PaperStore(),
        currentIndex: .constant(0)
    )
}