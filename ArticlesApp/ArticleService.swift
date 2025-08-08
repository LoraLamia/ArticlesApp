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
        "Authorization" : "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4OTYyNTVlMDdiN2MwYTVkZWZlMDhjMCIsInVzZXJuYW1lIjoiam9obi5rdXBhdHR0Iiwicm9sZSI6IkJhc2ljIiwiaWF0IjoxNzU0NjcwNDMwLCJleHAiOjE3NTQ2ODEyMzB9.lAU13kvwlI6jd9W7nbj18EMiy1lkT1oL1wpEkyx4pTE"
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
