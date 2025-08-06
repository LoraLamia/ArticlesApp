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
    
    var currentPage = 1
    var isLoadingMore = false
    var allArticlesLoaded = false
    
    let articlesTableView = UITableView()
    let searchTextField = UITextField()
    var articles: [Article] = []
    var filteredArticles: [Article] = []
    var searchWorkItem: DispatchWorkItem?
    
    let headers: HTTPHeaders = [
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4OTM0OGJiMWUwNjM0NmZhYjE1NDc4NyIsInVzZXJuYW1lIjoiam9obi5kb2UudGhpcmQiLCJyb2xlIjoiQmFzaWMiLCJpYXQiOjE3NTQ0ODI4NzUsImV4cCI6MTc1NDQ5MzY3NX0.cSW4ZORedw2_2qppbYgLT01tH9HvwEEVjIPYkA3vqA0"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextField()
        setupTableView()
        fetchArticles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        articlesTableView.reloadData()
    }
    
    private func setupTextField() {
        view.addSubview(searchTextField)
        
        searchTextField.placeholder = "Search Articles"
        searchTextField.borderStyle = .roundedRect
        searchTextField.backgroundColor = .systemGray6
        searchTextField.addTarget(self, action: #selector(searchTextFieldChanged), for: .editingChanged)
        
        searchTextField.autoPinEdge(toSuperviewSafeArea: .top)
        searchTextField.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        searchTextField.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        searchTextField.autoSetDimension(.height, toSize: 40)
    }
    
    @objc private func searchTextFieldChanged() {
        searchWorkItem?.cancel()
        
        let searchText = searchTextField.text?.lowercased() ?? ""
        
        searchWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            if searchText.isEmpty {
                self.filteredArticles = self.articles
            } else {
                self.filteredArticles = self.articles.filter { article in
                    
                    let title = article.title.lowercased().contains(searchText)
                    let summary = article.summary.lowercased().contains(searchText)
                    let author = article.author.lowercased().contains(searchText)
                    let topic = article.topic.lowercased().contains(searchText)
                    let tags = article.tags.contains { tag in
                        tag.lowercased().contains(searchText)
                    }
                    return title || summary || author || topic || tags
                }
            }
            
            DispatchQueue.main.async {
                self.articlesTableView.reloadData()
            }
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: searchWorkItem!)
    }
    
    private func setupTableView() {
        view.addSubview(articlesTableView)
    
        articlesTableView.rowHeight = UITableView.automaticDimension
        articlesTableView.delegate = self
        articlesTableView.dataSource = self
        articlesTableView.register(ArticlesTableViewCell.self, forCellReuseIdentifier: "ArticlesTableViewCell")
        
        articlesTableView.autoPinEdge(.top, to: .bottom, of: searchTextField, withOffset: 8)
        articlesTableView.autoPinEdge(toSuperviewEdge: .leading)
        articlesTableView.autoPinEdge(toSuperviewEdge: .trailing)
        articlesTableView.autoPinEdge(toSuperviewSafeArea: .bottom)
    }
    
    private func fetchArticles() {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        
        let parameters: [String: String] = [
            "page": "\(currentPage)",
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
        .responseDecodable(of: ArticlesResponse.self) { [weak self] dataResponse in
            guard let self = self else { return }
            self.isLoadingMore = false
            
            switch dataResponse.result {
            case .success(let articlesResponse):
                self.handleSuccesCase(articlesResponse: articlesResponse)
            case .failure:
                self.handleErrorCase()
            }
        }
    }
    
    private func handleSuccesCase(articlesResponse: ArticlesResponse) {
        let moreArticles = articlesResponse.articles.data
        
        if moreArticles.isEmpty {
            self.allArticlesLoaded = true
            return
        }
        
        self.articles.append(contentsOf: moreArticles)
        self.filteredArticles = self.articles
        
        self.currentPage += 1
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
        filteredArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = filteredArticles[indexPath.row]
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

extension ArticlesViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 100 {
            if !isLoadingMore && !allArticlesLoaded {
                fetchArticles()
            }
        }
    }
    
}
