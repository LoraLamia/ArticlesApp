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
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No favorites yet!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupEmptyLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favoritesTableView.reloadData()
        updateEmptyState()
    }
    
    private func setupTableView() {
        view.addSubview(favoritesTableView)
        favoritesTableView.autoPinEdgesToSuperviewEdges()
        favoritesTableView.rowHeight = UITableView.automaticDimension
        
        favoritesTableView.delegate = self
        favoritesTableView.dataSource = self
        favoritesTableView.register(ArticlesTableViewCell.self, forCellReuseIdentifier: "ArticlesTableViewCell")
    }
    
    private func setupEmptyLabel() {
            view.addSubview(emptyLabel)
            emptyLabel.autoAlignAxis(toSuperviewAxis: .vertical)
            emptyLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        }
        
        private func updateEmptyState() {
            let isEmpty = FavoritesSingleton.shared.favoritesArticles.isEmpty
            emptyLabel.isHidden = !isEmpty
            favoritesTableView.isHidden = isEmpty
        }

}


extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoritesSingleton.shared.favoritesArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = FavoritesSingleton.shared.favoritesArticles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticlesTableViewCell", for: indexPath) as! ArticlesTableViewCell
        cell.delegate = self
        cell.configure(article: article)
        return cell
    }
        
}



extension FavoritesViewController: ArticlesTableViewCellDelegate {
    func didTapFavoriteButton(article: Article) {
        if FavoritesSingleton.shared.isFavorite(article) {
            FavoritesSingleton.shared.removeFromFavorites(article: article)
        }
        favoritesTableView.reloadData()
        updateEmptyState()
    }
    
    
}
