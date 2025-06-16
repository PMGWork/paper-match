import Foundation
import SwiftUI
import Combine

class PaperStore: ObservableObject {
    @Published var papers: [Paper] = []
    @Published var savedPapers: [Paper] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let arXivService = ArXivService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSavedPapers()
        loadPapersFromAPI()
    }
    
    private func loadPapersFromAPI() {
        // Default query for initial load
        let defaultQuery = "cat:cs.AI OR cat:cs.LG OR cat:cs.CL OR cat:cs.CV"
        searchPapers(query: defaultQuery)
    }
    
    private func loadSavedPapers() {
        if let data = UserDefaults.standard.data(forKey: "savedPapers"),
           let decodedPapers = try? JSONDecoder().decode([Paper].self, from: data) {
            savedPapers = decodedPapers
        }
    }
    
    func likePaper(_ paper: Paper) {
        var likedPaper = paper
        likedPaper.isLiked = true
        
        if !savedPapers.contains(where: { $0.id == paper.id }) {
            savedPapers.append(likedPaper)
            savePapersToUserDefaults()
        }
    }
    
    func removeSavedPaper(_ paper: Paper) {
        savedPapers.removeAll { $0.id == paper.id }
        savePapersToUserDefaults()
    }
    
    private func savePapersToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(savedPapers) {
            UserDefaults.standard.set(encoded, forKey: "savedPapers")
        }
    }
    
    func refreshPapers() {
        let defaultQuery = "cat:cs.AI OR cat:cs.LG OR cat:cs.CL OR cat:cs.CV"
        searchPapers(query: defaultQuery)
    }
    
    func searchPapers(query: String) {
        isLoading = true
        errorMessage = nil
        
        arXivService.searchPapers(query: query)
            .sink(
                receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        if case .failure(let error) = completion {
                            self?.errorMessage = "Using sample papers (API unavailable)"
                            print("API Error: \(error.localizedDescription)")
                        }
                    }
                },
                receiveValue: { [weak self] papers in
                    DispatchQueue.main.async {
                        self?.papers = papers
                        if papers.isEmpty {
                            self?.errorMessage = "No papers found. Try different search terms."
                        } else {
                            self?.errorMessage = nil
                        }
                    }
                }
            )
            .store(in: &cancellables)
    }
}