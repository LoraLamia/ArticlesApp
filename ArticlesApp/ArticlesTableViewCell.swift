//
//  FavoritesTableViewCell.swift
//  ArticlesApp
//
//  Created by Lora Zubic on 05.08.2025..
//

import UIKit
import PureLayout

class ArticlesTableViewCell: UITableViewCell {
    
    weak var delegate: ArticlesTableViewCellDelegate?
    
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let dateLabel = UILabel()
    private let favoriteButton = UIButton()
    
    private var article: Article?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(favoriteButton)
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.numberOfLines = 0
        
        authorLabel.font = .systemFont(ofSize: 14)
        dateLabel.font = .systemFont(ofSize: 12)
        
        favoriteButton.addTarget(self, action: #selector(favoriteButtonPressed), for: .touchUpInside)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        favoriteButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        favoriteButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        favoriteButton.autoSetDimensions(to: CGSize(width: 30, height: 30))
        
        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 12)
        titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        titleLabel.autoPinEdge(.trailing, to: .leading, of: favoriteButton, withOffset: -12)
        
        authorLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 6)
        authorLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
        dateLabel.autoAlignAxis(.horizontal, toSameAxisOf: authorLabel)
        dateLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        dateLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 12)
    }
    
    @objc private func favoriteButtonPressed() {
        guard let article = article else { return }
        delegate?.didTapFavoriteButton(article: article)
        setImageForButton()
    }
    
    func configure(article: Article) {
        self.article = article
        
        titleLabel.text = article.title
        authorLabel.text = article.author
        
        setImageForButton()
    }
    
    private func setImageForButton() {
        guard let article = article else { return }
        let imageName = FavoritesSingleton.shared.isFavorite(article) ? "star.fill" : "star"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
}


protocol ArticlesTableViewCellDelegate: AnyObject {
    func didTapFavoriteButton(article: Article)
}

