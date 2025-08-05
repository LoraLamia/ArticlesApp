import Foundation

struct Article: Decodable {
    let id: String
    let title: String
    let summary: String
    let author: String
    let text: String
    let topic: String
    let tags: [String]
    let publishedAt: Date
}

extension Article {
    static let sampleData: [Article] = [
        Article(
            id: "1",
            title: "Swift 6 Released: Everything You Need to Know jhbejhafjewfjh giyadgjyawgdydga yuadguyawdgjy",
            summary: "Apple has officially released Swift 6 with new concurrency features.",
            author: "Ana Developer",
            text: "Swift 6 introduces structured concurrency, actors, and more. This release marks a significant step forward...",
            topic: "Programming",
            tags: ["Swift", "Apple", "iOS"],
            publishedAt: ISO8601DateFormatter().date(from: "2025-07-01T10:00:00Z")!
        ),
        Article(
            id: "2",
            title: "Design Trends in Mobile Apps 2025",
            summary: "A fresh look at the most popular UI/UX trends for mobile platforms.",
            author: "Marko Dizajner",
            text: "From glassmorphism to kinetic typography, this year is packed with innovation in mobile app design...",
            topic: "Design",
            tags: ["UI", "UX", "Mobile"],
            publishedAt: ISO8601DateFormatter().date(from: "2025-06-25T15:30:00Z")!
        ),
        Article(
            id: "3",
            title: "Why Everyone is Using Microservices in 2025",
            summary: "Microservices architecture has become the standard for scalable systems.",
            author: "Jelena Backend",
            text: "Microservices help teams scale independently and deploy faster. In this article, we’ll explore when and how to use them...",
            topic: "Backend",
            tags: ["Architecture", "Microservices", "DevOps"],
            publishedAt: ISO8601DateFormatter().date(from: "2025-05-10T08:45:00Z")!
        )
    ]
}

