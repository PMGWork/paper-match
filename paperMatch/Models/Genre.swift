import Foundation
import Combine

struct Genre: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var query: String
    var isDefault: Bool
    var isEnabled: Bool = true
    
    init(name: String, query: String, isDefault: Bool = false) {
        self.name = name
        self.query = query
        self.isDefault = isDefault
    }
}

class GenreManager: ObservableObject {
    @Published var genres: [Genre] = []
    @Published var enabledGenres: [Genre] = []
    
    private let userDefaultsKey = "savedGenres"
    
    init() {
        loadGenres()
        updateEnabledGenres()
    }
    
    private func loadGenres() {
        // Load custom genres from UserDefaults
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let savedGenres = try? JSONDecoder().decode([Genre].self, from: data) {
            let customGenres = savedGenres.filter { !$0.isDefault }
            genres = defaultGenres + customGenres
        } else {
            genres = defaultGenres
        }
    }
    
    private var defaultGenres: [Genre] {
        [
            Genre(name: "AI & Machine Learning", query: "cat:cs.AI OR cat:cs.LG OR cat:stat.ML", isDefault: true),
            Genre(name: "Computer Vision", query: "cat:cs.CV", isDefault: true),
            Genre(name: "Natural Language Processing", query: "cat:cs.CL", isDefault: true),
            Genre(name: "Robotics", query: "cat:cs.RO", isDefault: true),
            Genre(name: "Neural Networks", query: "cat:cs.NE", isDefault: true),
            Genre(name: "Human-Computer Interaction", query: "cat:cs.HC", isDefault: true),
            Genre(name: "Computer Graphics", query: "cat:cs.GR", isDefault: true),
            Genre(name: "Distributed Computing", query: "cat:cs.DC", isDefault: true),
            Genre(name: "Cryptography", query: "cat:cs.CR", isDefault: true),
            Genre(name: "Information Theory", query: "cat:cs.IT", isDefault: true)
        ]
    }
    
    func addCustomGenre(name: String, query: String) {
        let newGenre = Genre(name: name, query: query, isDefault: false)
        genres.append(newGenre)
        saveCustomGenres()
        updateEnabledGenres()
    }
    
    func removeGenre(_ genre: Genre) {
        if !genre.isDefault {
            genres.removeAll { $0.id == genre.id }
            saveCustomGenres()
            updateEnabledGenres()
        }
    }
    
    func toggleGenre(_ genre: Genre) {
        if let index = genres.firstIndex(where: { $0.id == genre.id }) {
            genres[index].isEnabled.toggle()
            saveCustomGenres()
            updateEnabledGenres()
        }
    }
    
    private func updateEnabledGenres() {
        enabledGenres = genres.filter { $0.isEnabled }
    }
    
    private func saveCustomGenres() {
        let customGenres = genres.filter { !$0.isDefault }
        if let data = try? JSONEncoder().encode(customGenres) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
        
        // Also save the enabled state for all genres
        let genreStates = genres.map { ["id": $0.id.uuidString, "isEnabled": $0.isEnabled] }
        UserDefaults.standard.set(genreStates, forKey: "genreStates")
    }
    
    func getRandomQuery() -> String {
        guard !enabledGenres.isEmpty else {
            return defaultGenres.first?.query ?? "cat:cs.AI"
        }
        
        let queries = enabledGenres.map { $0.query }
        return queries.joined(separator: " OR ")
    }
}
