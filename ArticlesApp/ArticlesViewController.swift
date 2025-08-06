//
//  ArticlesViewController.swift
//  ArticlesApp
//
//  Created by Lora Zubic on 05.08.2025..
//

import UIKit
import PureLayout
import Alamofire
import MBProgressHUD

class ArticlesViewController: UIViewController {
    
    let articlesTableView = UITableView()
    var articles: [Article] = []
    //    var mockArticles = Article.sampleData
    let headers: HTTPHeaders = [
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4OTMwNzk2MWUwNjM0NmZhYjE1NDcxOSIsInVzZXJuYW1lIjoiam9obi5kb2Uuc2Vjb25kIiwicm9sZSI6IkJhc2ljIiwiaWF0IjoxNzU0NDY2MTk4LCJleHAiOjE3NTQ0NzY5OTh9.lLTfwg4ug1xLLNr3gp3HGHbLAVAGHCzihGFgFtz6W3o"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        fetchArticles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        articlesTableView.reloadData()
    }
    
    private func setupTableView() {
        view.addSubview(articlesTableView)
        articlesTableView.autoPinEdgesToSuperviewEdges()
        articlesTableView.rowHeight = UITableView.automaticDimension
        
        articlesTableView.delegate = self
        articlesTableView.dataSource = self
        
        articlesTableView.register(ArticlesTableViewCell.self, forCellReuseIdentifier: "ArticlesTableViewCell")
    }
    
    private func fetchArticles() {
        
        AF.request(
            "http://localhost:3000/api/articles",
            method: .get,
            parameters: ["page": "1", "pageSize": "20", "sort": "-1"],
            headers: headers
        )
        .validate()
        .responseDecodable(of: ArticlesResponse.self) { [weak self] dataResponse in
            guard let self = self else { return }
            
            switch dataResponse.result {
            case .success(let articlesResponse):
                print(articlesResponse)
                self.handleSuccesCase(articlesResponse: articlesResponse)
            case .failure:
                self.handleErrorCase()
            }
        }
    }
    
    private func handleSuccesCase(articlesResponse: ArticlesResponse) {
        self.articles = articlesResponse.articles.data
        self.articlesTableView.reloadData()
    }
    
    private func handleErrorCase() {
        let alert = UIAlertController(title: "Error", message: "Could not fetch data", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    
}

extension ArticlesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = articles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticlesTableViewCell", for: indexPath) as! ArticlesTableViewCell
        cell.delegate = self
        cell.configure(article: article)
        return cell
    }
    
}


extension ArticlesViewController: ArticlesTableViewCellDelegate {
    func didTapFavoriteButton(article: Article) {
        
        FavoritesSingleton.shared.isFavorite(article) ? FavoritesSingleton.shared.removeFromFavorites(article: article) : FavoritesSingleton.shared.addToFavorites(article: article)
    }
}
