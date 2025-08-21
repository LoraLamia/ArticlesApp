//
//  FavoritesManager.swift
//  ArticlesApp
//
//  Created by Lora Zubic on 06.08.2025..
//

class FavoritesManager {
    static let shared = FavoritesManager()

    // use `let` or `private(set) var`, nobody should be able to update this from the outside,
    // that's why we have FavoritesManager that handles adding and removing
    var favoritesArticles: [Article] = []
    
    private init() {
        // this would be a good place to load favorites from UserDefaults
    }


    // no persistence, favorites will disappear on realunch
    func addToFavorites(article: Article) {
        if !favoritesArticles.contains(where: { $0.id == article.id }) {
            favoritesArticles.append(article)
        }
    }
    
    func removeFromFavorites(article: Article) {
        favoritesArticles.removeAll { $0.id == article.id }
    }
    
    func isFavorite(_ article: Article) -> Bool {
        return favoritesArticles.contains { $0.id == article.id }
    }
}
