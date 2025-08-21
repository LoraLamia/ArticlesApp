//
//  ArticlesViewController.swift
//  ArticlesApp
//
//  Created by Lora Zubic on 05.08.2025..
//

import UIKit
import PureLayout
import MBProgressHUD

// big class, i'd suggest separating with extensions into networking, UI methods, TableController delegate methods etc.
class ArticlesViewController: UIViewController {
    
    private var currentPage = 1
    private var isLoadingMore = false
    private var allArticlesLoaded = false
    private var isDescendingSort = false
    private var selectedTopic = "all articles" // extract to Constants
    private var articles: [Article] = []
    private var filteredArticles: [Article] = []
    private var topics: [String] = []
    private var isSearching: Bool {
        // much simpler
        // return searchTextField.text?.isEmpty ?? false

        guard let text = searchTextField.text else { return false }
        return !text.isEmpty
    }
    
    private var searchWorkItem: DispatchWorkItem?
    private var articleService = ArticleService()
    
    private let articlesTableView = UITableView()
    private let searchTextField = UITextField()
    private let sortButton = UIButton()
    private let refreshControl = UIRefreshControl()
    private let topicsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setupConstraints()
        styleViews()
        setupTableView()
        setupCollectionView()
        addActions()
        fetchArticles()
        fetchTopics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        articlesTableView.reloadData()
    }

    // ok, but more modern approach would be to use Combine .throttle or .debounce
    @objc private func searchTextFieldChanged() {
        searchWorkItem?.cancel()
        
        searchWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            let searchText = self.searchTextField.text?.lowercased() ?? ""
            
            if searchText.isEmpty {
                if self.selectedTopic == "all articles" {
                    self.filteredArticles = self.articles
                } else {
                    self.filteredArticles = self.articles.filter { $0.topic == self.selectedTopic }
                }
            } else {
                let baseArticles: [Article]
                if self.selectedTopic == "all articles" {
                    baseArticles = self.articles
                } else {
                    baseArticles = self.articles.filter { $0.topic == self.selectedTopic }
                }
                
                self.filteredArticles = baseArticles.filter { article in
                    
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
            
            self.sortArticlesByDate()
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: searchWorkItem!)
    }
    
    @objc private func refreshArticles() {
        guard selectedTopic == "all articles" && !isSearching else {
            refreshControl.endRefreshing()
            return
        }
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
    
    private func addSubviews() {
        view.addSubview(searchTextField)
        view.addSubview(articlesTableView)
        view.addSubview(sortButton)
        view.addSubview(topicsCollectionView)
    }
    
    private func addActions() {
        searchTextField.addTarget(self, action: #selector(searchTextFieldChanged), for: .editingChanged)
        sortButton.addTarget(self, action: #selector(sortArticles), for: .touchUpInside)
        refreshControl.addTarget(self, action: #selector(refreshArticles), for: .valueChanged)
    }
    
    private func setupTableView() {
        articlesTableView.rowHeight = UITableView.automaticDimension
        articlesTableView.delegate = self
        articlesTableView.dataSource = self
        articlesTableView.register(ArticlesTableViewCell.self, forCellReuseIdentifier: "ArticlesTableViewCell") // extract identifier to Constants
        articlesTableView.refreshControl = refreshControl
    }
    
    private func setupCollectionView() {
        topicsCollectionView.delegate = self
        topicsCollectionView.dataSource = self
        topicsCollectionView.register(TopicCollectionViewCell.self, forCellWithReuseIdentifier: "TopicCollectionViewCell") // extract identifier to Constants
    }
    
    private func styleViews() {
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
        
        topicsCollectionView.autoPinEdge(.top, to: .bottom, of: searchTextField, withOffset: 12)
        topicsCollectionView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        topicsCollectionView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        topicsCollectionView.autoSetDimension(.height, toSize: 50)
        
        articlesTableView.autoPinEdge(.top, to: .bottom, of: topicsCollectionView, withOffset: 12)
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

        // fetchArticles completion updates arrays and calls sortArticlesByDate() -> reloadData()
        // if service completes off-main, that’s a problem, so it's best to ensure that ui updates on main thread

        articleService.fetchArticles(page: currentPage) { [weak self] result in // why weak self here
            //DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isLoadingMore = false
                self.refreshControl.endRefreshing()
                
                switch result {
                case .success(let newArticles):
                    self.handleSuccesCase(newArticles: newArticles)
                case .failure(_):
                    self.handleErrorCase()
                }
            //}
        }
    }
    
    private func fetchTopics() {
        articleService.fetchTopics(completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let topics):
                self.topics = ["all articles"] + topics
                DispatchQueue.main.async {
                    self.topicsCollectionView.reloadData()
                }
            case .failure(_):
                print("failed to fetch topics")
            }
        })
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ArticlesTableViewCell", for: indexPath) as? ArticlesTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.configure(article: article)
        return cell
    }
}

extension ArticlesViewController: ArticlesTableViewCellDelegate {
    func didTapFavoriteButton(article: Article) {
        
        FavoritesManager.shared.isFavorite(article) ? FavoritesManager.shared.removeFromFavorites(article: article) : FavoritesManager.shared.addToFavorites(article: article)
    }
}

extension ArticlesViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard selectedTopic == "all articles" && !isSearching, scrollView is UITableView else { return }
        
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

extension ArticlesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let topic = topics[indexPath.row]
        guard let cell = topicsCollectionView.dequeueReusableCell(withReuseIdentifier: "TopicCollectionViewCell", for: indexPath) as? TopicCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let isSelected = topic == selectedTopic
        cell.configure(topic: topic, selected: isSelected)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let topic = topics[indexPath.row]
        selectedTopic = topic
        
        searchTextField.text = ""
        
        if topic == "all articles" {
            filteredArticles = articles
        } else {
            filteredArticles = articles.filter { $0.topic == topic }
        }
        sortArticlesByDate()
        
        collectionView.collectionViewLayout.invalidateLayout() //this line is here because collectionview has problems with automatic dimension
        collectionView.reloadData()
    }
    
}
