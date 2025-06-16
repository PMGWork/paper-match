import SwiftUI
import Combine

struct HomeView: View {
    @ObservedObject var paperStore: PaperStore
    @ObservedObject var genreManager: GenreManager
    
    @State private var currentIndex = 0
    @State private var dragOffset = CGSize.zero
    @State private var isShowingSearch = false
    @State private var isShowingGenreSettings = false
    
    private let swipeThreshold: CGFloat = 100
    private let maxRotation: Double = 15
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if paperStore.isLoading {
                    loadingView
                } else if currentIndex >= paperStore.papers.count {
                    emptyStateView
                } else {
                    VStack(spacing: 16) {
                        // Quick Genre Tags
                        if !genreManager.enabledGenres.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(genreManager.enabledGenres.prefix(5), id: \.id) { genre in
                                        QuickGenreTag(genre: genre) {
                                            currentIndex = 0
                                            paperStore.searchPapers(query: genre.query)
                                        }
                                    }
                                    
                                    if genreManager.enabledGenres.count > 5 {
                                        Button {
                                            isShowingGenreSettings = true
                                        } label: {
                                            Text("+\(genreManager.enabledGenres.count - 5)")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.blue)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.blue.opacity(0.1))
                                                .cornerRadius(12)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Paper Cards
                        GeometryReader { geometry in
                            if geometry.size.width > 0 && geometry.size.height > 0 {
                                cardStackView(geometry: geometry)
                            } else {
                                Color.clear
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                if let errorMessage = paperStore.errorMessage {
                    errorBanner(message: errorMessage)
                }
            }
            .navigationTitle("Paper Match")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isShowingSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingGenreSettings = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingSearch) {
            SearchView(paperStore: paperStore, genreManager: genreManager, currentIndex: $currentIndex)
        }
        .sheet(isPresented: $isShowingGenreSettings) {
            GenreTagsView(genreManager: genreManager, paperStore: paperStore, currentIndex: $currentIndex)
        }
        .onAppear {
            if paperStore.papers.isEmpty && !paperStore.isLoading {
                refreshPapers()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No more papers")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Check back later for new papers")
                .font(.body)
                .foregroundColor(.secondary)
            
            Button("Refresh") {
                refreshPapers()
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func refreshPapers() {
        currentIndex = 0
        let query = genreManager.getRandomQuery()
        paperStore.searchPapers(query: query)
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading papers...")
                .font(.title2)
                .foregroundColor(.secondary)
        }
    }
    
    private func errorBanner(message: String) -> some View {
        VStack {
            Spacer()
            
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Retry") {
                    refreshPapers()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    private func cardStackView(geometry: GeometryProxy) -> some View {
        let safeWidth = max(200, geometry.size.width - 40)
        let safeHeight = max(300, geometry.size.height - 200)
        let cardWidth = min(safeWidth, 400)
        let cardHeight = min(safeHeight, 600)
        
        return ZStack {
            ForEach(Array(paperStore.papers.enumerated()), id: \.element.id) { index, paper in
                if index >= currentIndex && index < currentIndex + 2 {
                    PaperCardView(paper: paper, dragOffset: index == currentIndex ? $dragOffset : .constant(.zero))
                        .frame(width: cardWidth, height: cardHeight)
                        .offset(
                            x: index == currentIndex ? dragOffset.width : 0,
                            y: CGFloat(index - currentIndex) * 8
                        )
                        .rotationEffect(.degrees(
                            index == currentIndex ? Double(dragOffset.width / 10) : 0
                        ))
                        .scaleEffect(
                            index == currentIndex ? 1.0 : 0.95
                        )
                        .opacity(index == currentIndex ? 1.0 : 0.6)
                        .zIndex(Double(10 - (index - currentIndex)))
                        .gesture(
                            index == currentIndex ? 
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation
                                }
                                .onEnded { value in
                                    handleSwipeEnd(translation: value.translation)
                                }
                            : nil
                        )
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: dragOffset)
                }
            }
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
    }
    
    private func handleSwipeEnd(translation: CGSize) {
        let swipeDirection = translation.width > 0 ? SwipeDirection.right : SwipeDirection.left
        let magnitude = abs(translation.width)
        
        if magnitude > swipeThreshold {
            performSwipe(direction: swipeDirection)
        } else {
            withAnimation(.spring()) {
                dragOffset = .zero
            }
        }
    }
    
    private func performSwipe(direction: SwipeDirection) {
        guard currentIndex < paperStore.papers.count else { return }
        
        let currentPaper = paperStore.papers[currentIndex]
        
        withAnimation(.easeInOut(duration: 0.3)) {
            dragOffset.width = direction == .right ? 1000 : -1000
        }
        
        if direction == .right {
            paperStore.likePaper(currentPaper)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentIndex += 1
            dragOffset = .zero
        }
    }
    
    enum SwipeDirection {
        case left, right
    }
}

struct QuickGenreTag: View {
    let genre: Genre
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(genre.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue)
                .cornerRadius(12)
        }
    }
}

#Preview {
    HomeView(paperStore: PaperStore(), genreManager: GenreManager())
}