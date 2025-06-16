import SwiftUI

struct FontModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 28, weight: .bold, design: .default))
    }
}

struct PaperCardView: View {
    @State var paper: Paper
    @Binding var dragOffset: CGSize
    @State private var rotationAngle: Double = 0
    @State private var showTranslation = false
    @State private var isTranslating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(paper.source.rawValue)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(sourceColor)
                    .cornerRadius(4)
                
                Spacer()
                
                // Translation Toggle Button
                Button {
                    toggleTranslation()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: showTranslation ? "textformat.123" : "character.book.closed.fill")
                            .font(.caption)
                        Text(showTranslation ? "EN" : "JP")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
                }
                .disabled(isTranslating)
                
                Text(paper.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                if isTranslating {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("翻訳中...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(displayTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .animation(.easeInOut, value: showTranslation)
            }
            
            Text(paper.authorsString)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Text(displayAbstract)
                .font(.body)
                .lineLimit(8)
                .fixedSize(horizontal: false, vertical: true)
                .animation(.easeInOut, value: showTranslation)
            
            HStack {
                ForEach(Array(paper.categories.prefix(3)), id: \.self) { category in
                    Text(category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
                Spacer()
            }
            
            Spacer(minLength: 20)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 400)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .offset(dragOffset)
        .rotationEffect(.degrees(rotationAngle))
        .overlay(
            swipeIndicatorOverlay,
            alignment: .center
        )
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
    
    @ViewBuilder
    private var swipeIndicatorOverlay: some View {
        if abs(dragOffset.width) > 50 {
            let isLike = dragOffset.width > 0
            let iconName = isLike ? "heart.fill" : "xmark"
            let overlayColor = isLike ? Color.green : Color.red
            let rotation = isLike ? -15.0 : 15.0
            let scale = min(abs(dragOffset.width) / 150.0, 1.5)
            
            RoundedRectangle(cornerRadius: 16)
                .stroke(overlayColor, lineWidth: 3)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: iconName)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(overlayColor)
                            .scaleEffect(scale)
                        
                        Text(isLike ? "LIKE" : "PASS")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(overlayColor)
                    }
                    .rotationEffect(.degrees(rotation))
                )
                .opacity(min(abs(dragOffset.width) / 100.0, 0.9))
        }
    }
    
    // MARK: - Translation Methods
    
    private var displayTitle: String {
        if showTranslation, let translatedTitle = paper.translatedTitle {
            return translatedTitle
        }
        return paper.title
    }
    
    private var displayAbstract: String {
        if showTranslation, let translatedAbstract = paper.translatedAbstract {
            return translatedAbstract
        }
        return paper.abstract
    }
    
    private func toggleTranslation() {
        if showTranslation {
            // Switch back to original
            showTranslation = false
        } else {
            // Show translation or translate if needed
            if paper.translatedTitle == nil || paper.translatedAbstract == nil {
                translatePaper()
            } else {
                showTranslation = true
            }
        }
    }
    
    private func translatePaper() {
        isTranslating = true
        
        Task {
            do {
                let textsToTranslate = [paper.title, paper.abstract]
                let translatedTexts = try await TranslationService.shared.batchTranslate(texts: textsToTranslate)
                
                await MainActor.run {
                    paper.translatedTitle = translatedTexts[0]
                    paper.translatedAbstract = translatedTexts[1]
                    showTranslation = true
                    isTranslating = false
                }
            } catch {
                await MainActor.run {
                    isTranslating = false
                    print("翻訳エラー: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    PaperCardView(paper: Paper.samplePapers[0], dragOffset: .constant(.zero))
        .padding()
}
