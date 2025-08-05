//
//  FavoritesTableViewCell.swift
//  ArticlesApp
//
//  Created by Lora Zubic on 05.08.2025..
//

import UIKit
import PureLayout

class ArticlesTableViewCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let dateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//        // Configure the view for the selected state
//    }
    
    private func setupViews() {

        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(dateLabel)
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.numberOfLines = 0
        
        authorLabel.font = .systemFont(ofSize: 14)
        dateLabel.font = .systemFont(ofSize: 12)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 12)
        titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        titleLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        authorLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 6)
        authorLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
        dateLabel.autoAlignAxis(.horizontal, toSameAxisOf: authorLabel)
        dateLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        dateLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 12)
    }
    
    func configure(with article: Article) {
        titleLabel.text = article.title
        authorLabel.text = article.author
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
//        dateLabel.text = article.publishedAt
    }
    
}
