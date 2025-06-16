import SwiftUI

struct MainTabView: View {
    @StateObject private var paperStore = PaperStore()
    @StateObject private var genreManager = GenreManager()
    
    var body: some View {
        TabView {
            HomeView(paperStore: paperStore, genreManager: genreManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            LibraryView(paperStore: paperStore, genreManager: genreManager)
                .tabItem {
                    Image(systemName: "books.vertical.fill")
                    Text("Library")
                }
        }
        .environmentObject(paperStore)
        .environmentObject(genreManager)
    }
}