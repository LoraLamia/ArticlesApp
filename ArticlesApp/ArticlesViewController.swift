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
    private let sortButton = UIButton()
    
    private var articles: [Article] = []
    private var filteredArticles: [Article] = []
    private var searchWorkItem: DispatchWorkItem?
    private var articleService = ArticleService()
    
    private let refreshControl = UIRefreshControl()
    
    let headers: HTTPHeaders = [
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4OTViODEzNWUyODJlMjMzZDc1NGU1ZiIsInVzZXJuYW1lIjoiam9obi5kb2UudGVzdGlyYW5qZTUiLCJyb2xlIjoiQmFzaWMiLCJpYXQiOjE3NTQ2NDI0NTEsImV4cCI6MTc1NDY1MzI1MX0.SN5C0nibRDo9x5aAft40pyN1ONivuin1JbZsJTx6oP0"
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
    
    @objc private func refreshArticles() {
        currentPage = 1
        allArticlesLoaded = false
        articles.removeAll()
        filteredArticles.removeAll()
        articlesTableView.reloadData()
        fetchArticles()
    }
    
    @objc private func sortArticles() {
        isDescendingSort.toggle()
        
        let imageName = isDescendingSort ? "arrow.up" : "arrow.down"
        sortButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        sortArticlesByDate()
    }
    
    
    private func setupViews() {
        view.addSubview(searchTextField)
        view.addSubview(articlesTableView)
        view.addSubview(sortButton)
        
        searchTextField.addTarget(self, action: #selector(searchTextFieldChanged), for: .editingChanged)
        
        articlesTableView.rowHeight = UITableView.automaticDimension
        articlesTableView.delegate = self
        articlesTableView.dataSource = self
        articlesTableView.register(ArticlesTableViewCell.self, forCellReuseIdentifier: "ArticlesTableViewCell")
        
        refreshControl.addTarget(self, action: #selector(refreshArticles), for: .valueChanged)
        articlesTableView.refreshControl = refreshControl
        
        sortButton.addTarget(self, action: #selector(sortArticles), for: .touchUpInside)
        
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
        
        sortButton.setImage(UIImage(systemName: "arrow.down"), for: .normal)
    }
    
    private func setupConstraints() {
        searchTextField.autoPinEdge(toSuperviewSafeArea: .top)
        searchTextField.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        searchTextField.autoSetDimension(.height, toSize: 40)
        
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 40))
        searchTextField.leftView = padding
        searchTextField.leftViewMode = .always
        
        sortButton.autoPinEdge(toSuperviewSafeArea: .top, withInset: 6)
        sortButton.autoPinEdge(.leading, to: .trailing, of: searchTextField, withOffset: 6)
        sortButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        articlesTableView.autoPinEdge(.top, to: .bottom, of: searchTextField, withOffset: 12)
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
        guard !isLoadingMore || currentPage == 1 else { return }
        isLoadingMore = true
        
        articleService.fetchArticles(page: currentPage) { [weak self] result in
            guard let self = self else { return }
            self.isLoadingMore = false
            self.refreshControl.endRefreshing()
            
            switch result {
            case .success(let newArticles):
                self.handleSuccesCase(newArticles: newArticles)
            case .failure(_):
                self.handleErrorCase()
            }
        }
    }
    
    private func handleSuccesCase(newArticles: [Article]) {
        if newArticles.isEmpty {
            self.allArticlesLoaded = true
            return
        }
        
        self.articles.append(contentsOf: newArticles)
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
