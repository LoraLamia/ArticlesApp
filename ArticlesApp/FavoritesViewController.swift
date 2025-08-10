//
//  FavoritesViewController.swift
//  ArticlesApp
//
//  Created by Lora Zubic on 05.08.2025..
//

import UIKit
import PureLayout
import Alamofire

class FavoritesViewController: UIViewController {
    
    private let favoritesTableView = UITableView()
    private let emptyLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setupConstraints()
        styleViews()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favoritesTableView.reloadData()
        updateEmptyState()
    }
    
    private func addSubviews() {
        view.addSubview(favoritesTableView)
        view.addSubview(emptyLabel)
    }
    
    private func setupConstraints() {
        emptyLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        emptyLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        favoritesTableView.autoPinEdgesToSuperviewEdges()
    }
    
    private func styleViews() {
        emptyLabel.text = "No favorites yet!"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .gray
        emptyLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        emptyLabel.isHidden = true
    }
    
    private func setupTableView() {
        favoritesTableView.rowHeight = UITableView.automaticDimension
        favoritesTableView.delegate = self
        favoritesTableView.dataSource = self
        favoritesTableView.register(ArticlesTableViewCell.self, forCellReuseIdentifier: "ArticlesTableViewCell")
    }
    
    private func updateEmptyState() {
        let isEmpty = FavoritesManager.shared.favoritesArticles.isEmpty
        emptyLabel.isHidden = !isEmpty
        favoritesTableView.isHidden = isEmpty
    }
    
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoritesManager.shared.favoritesArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = FavoritesManager.shared.favoritesArticles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticlesTableViewCell", for: indexPath) as! ArticlesTableViewCell
        cell.delegate = self
        cell.configure(article: article)
        return cell
    }

}

extension FavoritesViewController: ArticlesTableViewCellDelegate {
    func didTapFavoriteButton(article: Article) {
        if FavoritesManager.shared.isFavorite(article) {
            FavoritesManager.shared.removeFromFavorites(article: article)
        }
        favoritesTableView.reloadData()
        updateEmptyState()
    }
    
}
