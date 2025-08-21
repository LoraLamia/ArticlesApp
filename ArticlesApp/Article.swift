//
//  Article.swift
//  ArticlesApp
//
//  Created by Lora Zubic on 05.08.2025..
//

import Foundation

struct Article: Codable {
    let id: String
    let title: String
    let summary: String
    let author: String
    let topic: String
    let tags: [String]

    // What if this property had some extra long and unnecessary name, like date_of_article_publishing,
    // but we still wanted to have it in our structure as publishedAt?
    let publishedAt: Date

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        summary = try container.decode(String.self, forKey: .summary)
        author = try container.decode(String.self, forKey: .author)
        topic = try container.decode(String.self, forKey: .topic)
        tags = try container.decode([String].self, forKey: .tags)

        let dateString = try container.decode(String.self, forKey: .publishedAt)

        // Created upon every init, not necessary
        // This could be extracted to DateParserService which would be a singleton
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(forKey: .publishedAt,
                in: container,
                debugDescription: "Date string does not match format expected by formatter.")
        }

        publishedAt = date
    }
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


