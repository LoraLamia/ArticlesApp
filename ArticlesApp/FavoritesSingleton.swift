//
//  FavoritesSingleton.swift
//  ArticlesApp
//
//  Created by Lora Zubic on 06.08.2025..
//

class FavoritesSingleton {
    static let shared = FavoritesSingleton()
    var favoritesArticles: [Article] = []
    
    private init() {}
    
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
