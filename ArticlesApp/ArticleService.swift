//
//  ArticleService.swift
//  ArticlesApp
//
//  Created by Lora Zubic on 08.08.2025..
//

import Foundation
import Alamofire

class ArticleService {
    private let headers: HTTPHeaders = [
        "Authorization" : "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4OTViODEzNWUyODJlMjMzZDc1NGU1ZiIsInVzZXJuYW1lIjoiam9obi5kb2UudGVzdGlyYW5qZTUiLCJyb2xlIjoiQmFzaWMiLCJpYXQiOjE3NTQ2NDI0NTEsImV4cCI6MTc1NDY1MzI1MX0.SN5C0nibRDo9x5aAft40pyN1ONivuin1JbZsJTx6oP0"
    ]
    
    func fetchArticles(page: Int, completion: @escaping (Result<[Article], AFError>) -> Void) {
        let parameters: [String: String] = [
            "page": "\(page)",
            "pageSize": "20",
            "sort": "-1"
        ]
        
        AF.request(
            "http://localhost:3000/api/articles",
            method: .get,
            parameters: parameters,
            headers: headers
        )
        .validate()
        .responseDecodable(of: ArticlesResponse.self) { response in
            switch response.result {
            case .success(let articleResponse):
                let articles = articleResponse.articles.data
                completion(.success(articles))
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
    }
}
