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
    
    let headers: HTTPHeaders = [
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4OTQ1NWI0YWIxYmYzNDM2MWQ1ZTcxNSIsInVzZXJuYW1lIjoiam9obi5kb2UuZm91cnRoNCIsInJvbGUiOiJCYXNpYyIsImlhdCI6MTc1NDU1MTczMiwiZXhwIjoxNzU0NTYyNTMyfQ.HcqbBuZiQTnzi3beZyCVW9RzfL9_xTWnh14kMgem7AU"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        fetchArticles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        articlesTableView.reloadData()
    }
    
    @objc private func searchTextFieldChanged() {
        let searchText = searchTextField.text?.lowercased() ?? ""
        
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
    
    private func setupViews() {
        view.addSubview(searchTextField)
        view.addSubview(articlesTableView)
        
        searchTextField.addTarget(self, action: #selector(searchTextFieldChanged), for: .editingChanged)
        
        articlesTableView.rowHeight = UITableView.automaticDimension
        articlesTableView.delegate = self
        articlesTableView.dataSource = self
        articlesTableView.register(ArticlesTableViewCell.self, forCellReuseIdentifier: "ArticlesTableViewCell")
        
        editViews()
        setupConstraints()
    }
    
    private func editViews() {
        searchTextField.backgroundColor = .systemGray6
        searchTextField.layer.cornerRadius = 12
        searchTextField.layer.borderWidth = 1.5
        searchTextField.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.4).cgColor
        
        searchTextField.textColor = .label
        searchTextField.font = .systemFont(ofSize: 14)
        searchTextField.placeholder = "Search articles"
    }
    
    private func setupConstraints() {
        searchTextField.autoPinEdge(toSuperviewSafeArea: .top)
        searchTextField.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        searchTextField.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        searchTextField.autoSetDimension(.height, toSize: 40)
        
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 40))
        searchTextField.leftView = padding
        searchTextField.leftViewMode = .always
        
        articlesTableView.autoPinEdge(.top, to: .bottom, of: searchTextField, withOffset: 12)
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
