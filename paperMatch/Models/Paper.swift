import Foundation

struct Paper: Identifiable, Codable {
    let id: String
    let title: String
    let authors: [String]
    let abstract: String
    let publishedDate: Date
    let source: PaperSource
    let categories: [String]
    let url: String
    let pdfUrl: String?
    var isLiked: Bool = false
    var isRead: Bool = false
    var translatedTitle: String?
    var translatedAbstract: String?
    
    enum PaperSource: String, CaseIterable, Codable {
        case arxiv = "ArXiv"
        case acm = "ACM"
        case ieee = "IEEE"
        case other = "Other"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: publishedDate)
    }
    
    var authorsString: String {
        authors.joined(separator: ", ")
    }
}

extension Paper {
    static let samplePapers: [Paper] = [
        Paper(
            id: "1",
            title: "Attention Is All You Need",
            authors: ["Ashish Vaswani", "Noam Shazeer", "Niki Parmar"],
            abstract: "The dominant sequence transduction models are based on complex recurrent or convolutional neural networks that include an encoder and a decoder. The best performing models also connect the encoder and decoder through an attention mechanism.",
            publishedDate: Date(timeIntervalSince1970: 1496275200),
            source: .arxiv,
            categories: ["Machine Learning", "Natural Language Processing"],
            url: "https://arxiv.org/abs/1706.03762",
            pdfUrl: "https://arxiv.org/pdf/1706.03762.pdf"
        ),
        Paper(
            id: "2",
            title: "BERT: Pre-training of Deep Bidirectional Transformers for Language Understanding",
            authors: ["Jacob Devlin", "Ming-Wei Chang", "Kenton Lee"],
            abstract: "We introduce a new language representation model called BERT, which stands for Bidirectional Encoder Representations from Transformers.",
            publishedDate: Date(timeIntervalSince1970: 1539648000),
            source: .arxiv,
            categories: ["Natural Language Processing", "Deep Learning"],
            url: "https://arxiv.org/abs/1810.04805",
            pdfUrl: "https://arxiv.org/pdf/1810.04805.pdf"
        ),
        Paper(
            id: "3",
            title: "GPT-3: Language Models are Few-Shot Learners",
            authors: ["Tom B. Brown", "Benjamin Mann", "Nick Ryder"],
            abstract: "Recent work has demonstrated substantial gains on many NLP tasks and benchmarks by pre-training on a large corpus of text followed by fine-tuning on a specific task.",
            publishedDate: Date(timeIntervalSince1970: 1590969600),
            source: .arxiv,
            categories: ["Natural Language Processing", "Large Language Models"],
            url: "https://arxiv.org/abs/2005.14165",
            pdfUrl: "https://arxiv.org/pdf/2005.14165.pdf"
        ),
        Paper(
            id: "4",
            title: "ResNet: Deep Residual Learning for Image Recognition",
            authors: ["Kaiming He", "Xiangyu Zhang", "Shaoqing Ren"],
            abstract: "Deeper neural networks are more difficult to train. We present a residual learning framework to ease the training of networks that are substantially deeper than those used previously.",
            publishedDate: Date(timeIntervalSince1970: 1512086400),
            source: .arxiv,
            categories: ["Computer Vision", "Deep Learning"],
            url: "https://arxiv.org/abs/1512.03385",
            pdfUrl: "https://arxiv.org/pdf/1512.03385.pdf"
        ),
        Paper(
            id: "5",
            title: "Vision Transformer: An Image is Worth 16x16 Words",
            authors: ["Alexey Dosovitskiy", "Lucas Beyer", "Alexander Kolesnikov"],
            abstract: "While the Transformer architecture has become the de-facto standard for natural language processing tasks, its applications to computer vision remain limited.",
            publishedDate: Date(timeIntervalSince1970: 1603756800),
            source: .arxiv,
            categories: ["Computer Vision", "Transformers"],
            url: "https://arxiv.org/abs/2010.11929",
            pdfUrl: "https://arxiv.org/pdf/2010.11929.pdf"
        ),
        Paper(
            id: "6",
            title: "Distributed Deep Learning for IoT Devices",
            authors: ["John Smith", "Alice Johnson", "Bob Wilson"],
            abstract: "Internet of Things (IoT) devices generate massive amounts of data that require efficient processing. This paper presents a novel approach to distributed deep learning specifically designed for resource-constrained IoT environments.",
            publishedDate: Date(timeIntervalSince1970: 1640995200),
            source: .ieee,
            categories: ["IoT", "Distributed Computing", "Deep Learning"],
            url: "https://ieeexplore.ieee.org/document/example1",
            pdfUrl: nil
        ),
        Paper(
            id: "7",
            title: "Quantum Computing Applications in Machine Learning",
            authors: ["Sarah Chen", "Michael Brown", "David Lee"],
            abstract: "Quantum computing promises to revolutionize machine learning by providing exponential speedups for certain algorithms. This survey explores current applications and future potential of quantum machine learning.",
            publishedDate: Date(timeIntervalSince1970: 1641081600),
            source: .acm,
            categories: ["Quantum Computing", "Machine Learning"],
            url: "https://dl.acm.org/doi/example1",
            pdfUrl: nil
        ),
        Paper(
            id: "8",
            title: "Federated Learning: Collaborative Machine Learning without Centralized Data",
            authors: ["Jessica Wang", "Ahmed Hassan", "Maria Garcia"],
            abstract: "Federated learning enables machine learning algorithms to gain experience from a broad range of data located at different sites without the data being centralized.",
            publishedDate: Date(timeIntervalSince1970: 1642291200),
            source: .arxiv,
            categories: ["Machine Learning", "Privacy", "Distributed Systems"],
            url: "https://arxiv.org/abs/example2",
            pdfUrl: "https://arxiv.org/pdf/example2.pdf"
        ),
        Paper(
            id: "9",
            title: "Graph Neural Networks for Social Network Analysis",
            authors: ["Robert Kim", "Lisa Zhang", "James Wilson"],
            abstract: "We present a comprehensive study of graph neural networks applied to social network analysis, demonstrating superior performance in link prediction and community detection tasks.",
            publishedDate: Date(timeIntervalSince1970: 1643500800),
            source: .ieee,
            categories: ["Graph Neural Networks", "Social Networks", "Deep Learning"],
            url: "https://ieeexplore.ieee.org/document/example2",
            pdfUrl: nil
        ),
        Paper(
            id: "10",
            title: "Reinforcement Learning for Autonomous Vehicle Navigation",
            authors: ["Elena Rodriguez", "Kevin Liu", "Amanda Foster"],
            abstract: "This paper explores the application of deep reinforcement learning to autonomous vehicle navigation in complex urban environments, achieving state-of-the-art performance in simulation.",
            publishedDate: Date(timeIntervalSince1970: 1644710400),
            source: .arxiv,
            categories: ["Reinforcement Learning", "Autonomous Vehicles", "Robotics"],
            url: "https://arxiv.org/abs/example3",
            pdfUrl: "https://arxiv.org/pdf/example3.pdf"
        )
    ]
}