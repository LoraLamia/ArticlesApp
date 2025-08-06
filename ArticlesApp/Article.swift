import Foundation

struct Article: Codable {
    let id: String
    let title: String
    let summary: String
    let author: String
    let topic: String
    let tags: [String]
    let publishedAt: String
}

extension Article {
    static let sampleData: [Article] = [
        Article(
            id: "1",
            title: "Swift 6 Released: Everything You Need to Know jhbejhafjewfjh giyadgjyawgdydga yuadguyawdgjy",
            summary: "Apple has officially released Swift 6 with new concurrency features.",
            author: "Ana Developer",
            topic: "Programming",
            tags: ["Swift", "Apple", "iOS"],
            publishedAt: ""
        ),
        Article(
            id: "2",
            title: "Design Trends in Mobile Apps 2025",
            summary: "A fresh look at the most popular UI/UX trends for mobile platforms.",
            author: "Marko Dizajner",
            topic: "Design",
            tags: ["UI", "UX", "Mobile"],
            publishedAt: ""
        ),
        Article(
            id: "3",
            title: "Why Everyone is Using Microservices in 2025",
            summary: "Microservices architecture has become the standard for scalable systems.",
            author: "Jelena Backend",
            topic: "Backend",
            tags: ["Architecture", "Microservices", "DevOps"],
            publishedAt: ""
        )
    ]
}


struct ArticlesResponse: Codable {
    let articles: ArticlesContainer
}

struct ArticlesContainer: Codable {
    let metadata: Metadata
    let data: [Article]
}

struct Metadata: Codable {
    let totalCount: Int
    let page: Int
    let pageSize: Int
}


