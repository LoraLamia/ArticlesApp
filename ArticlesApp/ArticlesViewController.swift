//
//  ArticlesViewController.swift
//  ArticlesApp
//
//  Created by Lora Zubic on 05.08.2025..
//

import UIKit
import PureLayout

class ArticlesViewController: UIViewController {
    
    let articlesTableView = UITableView()
    let mockArticles = Article.sampleData
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    private func setupTableView() {
        view.addSubview(articlesTableView)
        articlesTableView.autoPinEdgesToSuperviewEdges()
        articlesTableView.rowHeight = UITableView.automaticDimension
        
        articlesTableView.delegate = self
        articlesTableView.dataSource = self
        
        articlesTableView.register(ArticlesTableViewCell.self, forCellReuseIdentifier: "ArticlesTableViewCell")
    }
    
    
}

extension ArticlesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mockArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = mockArticles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticlesTableViewCell", for: indexPath) as! ArticlesTableViewCell
        cell.configure(with: article)
        return cell
    }
    
    
}
