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
        "Authorization" : "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4OTcwMmFlMDdiN2MwYTVkZWZlMGJmMCIsInVzZXJuYW1lIjoiam9obi5rdXBhdHR0aWkiLCJyb2xlIjoiQmFzaWMiLCJpYXQiOjE3NTQ3MjcwODYsImV4cCI6MTc1NDczNzg4Nn0.ZIXfWHa-yR4KJ2-fh9mkox9Rvy0cdUsqL32DXeOaIt8"
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
    
    func fetchTopics(completion: @escaping (Result<[String], AFError>) -> Void) {
        AF.request("http://localhost:3000/api/articles/topics", method: .get, headers: headers)
            .validate()
            .responseDecodable(of: [String].self) { response in
                switch response.result {
                case .success(let topics):
                    completion(.success(topics))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
