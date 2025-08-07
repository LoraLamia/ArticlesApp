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
    
    private var currentPage = 1
    private var isLoadingMore = false
    private var allArticlesLoaded = false
    private var isDescendingSort = false
    
    private let articlesTableView = UITableView()
    private let searchTextField = UITextField()
    private let sortingSegmentedControl = UISegmentedControl(items: ["Ascending", "Descending"])
    
    private var articles: [Article] = []
    private var filteredArticles: [Article] = []
    private var searchWorkItem: DispatchWorkItem?
    
    let headers: HTTPHeaders = [
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4OTQ4MThlYWIxYmYzNDM2MWQ1ZTdhNyIsInVzZXJuYW1lIjoiam9obi5kb2UuNjYiLCJyb2xlIjoiQmFzaWMiLCJpYXQiOjE3NTQ1NjI5NTgsImV4cCI6MTc1NDU3Mzc1OH0.FvkjmVotM27KaiUKYVivD4VkPgnVssrMYHhNnjNEFcU"
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
                self.sortArticlesByDate()
            }
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: searchWorkItem!)
    }
    
    @objc private func sortingChanged() {
        isDescendingSort = (sortingSegmentedControl.selectedSegmentIndex == 0)
        sortArticlesByDate()
    }
    
    
    private func setupViews() {
        view.addSubview(searchTextField)
        view.addSubview(articlesTableView)
        view.addSubview(sortingSegmentedControl)
        
        searchTextField.addTarget(self, action: #selector(searchTextFieldChanged), for: .editingChanged)
        
        articlesTableView.rowHeight = UITableView.automaticDimension
        articlesTableView.delegate = self
        articlesTableView.dataSource = self
        articlesTableView.register(ArticlesTableViewCell.self, forCellReuseIdentifier: "ArticlesTableViewCell")
        
        sortingSegmentedControl.selectedSegmentIndex = 0
        sortingSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        sortingSegmentedControl.addTarget(self, action: #selector(sortingChanged), for: .valueChanged)
        
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
        
        sortingSegmentedControl.selectedSegmentTintColor = .systemBlue.withAlphaComponent(0.5)
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemBlue
        ]
        
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]
        
        sortingSegmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        sortingSegmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
    }
    
    private func setupConstraints() {
        searchTextField.autoPinEdge(toSuperviewSafeArea: .top)
        searchTextField.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        searchTextField.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        searchTextField.autoSetDimension(.height, toSize: 40)
        
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 40))
        searchTextField.leftView = padding
        searchTextField.leftViewMode = .always
        
        sortingSegmentedControl.autoPinEdge(.top, to: .bottom, of: searchTextField, withOffset: 12)
        sortingSegmentedControl.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        sortingSegmentedControl.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        sortingSegmentedControl.autoSetDimension(.height, toSize: 30)
        
        articlesTableView.autoPinEdge(.top, to: .bottom, of: sortingSegmentedControl, withOffset: 12)
        articlesTableView.autoPinEdge(toSuperviewEdge: .leading)
        articlesTableView.autoPinEdge(toSuperviewEdge: .trailing)
        articlesTableView.autoPinEdge(toSuperviewSafeArea: .bottom)
    }
    
    private func sortArticlesByDate() {
        filteredArticles.sort {
            isDescendingSort ? $0.publishedAt > $1.publishedAt : $0.publishedAt < $1.publishedAt
        }
        articlesTableView.reloadData()
        
        DispatchQueue.main.async {
            self.articlesTableView.setContentOffset(.zero, animated: true)
        }
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
        self.sortArticlesByDate()
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
