//
//  FavoritesTableViewCell.swift
//  ArticlesApp
//
//  Created by Lora Zubic on 05.08.2025..
//

import UIKit
import PureLayout

protocol ArticlesTableViewCellDelegate: AnyObject {
    func didTapFavoriteButton(article: Article)
}

class ArticlesTableViewCell: UITableViewCell {
    
    weak var delegate: ArticlesTableViewCellDelegate?
    
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let dateLabel = UILabel()
    private let summaryLabel = UILabel()
    private let tagsAndTopicLabel = UILabel()
    private let favoriteButton = UIButton()
    
    private var article: Article?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        setupConstraints()
        styleViews()
        addActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
        authorLabel.text = ""
        dateLabel.text = ""
        summaryLabel.text = ""
        tagsAndTopicLabel.text = ""
    }
    
    private func addSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(summaryLabel)
        contentView.addSubview(tagsAndTopicLabel)
        contentView.addSubview(favoriteButton)
    }
    
    private func styleViews() {
        self.selectionStyle = .none
        
        contentView.backgroundColor = UIColor.systemGray6
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
        backgroundColor = .clear
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        
        authorLabel.font = .systemFont(ofSize: 14)
        authorLabel.textColor = .secondaryLabel
        
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryLabel
        
        summaryLabel.font = .systemFont(ofSize: 10)
        summaryLabel.textColor = .darkGray
        summaryLabel.numberOfLines = 0
        
        tagsAndTopicLabel.font = .systemFont(ofSize: 12)
        tagsAndTopicLabel.textColor = .systemBlue
        tagsAndTopicLabel.numberOfLines = 0
        
        favoriteButton.tintColor = .systemBlue
        favoriteButton.layer.shadowColor = UIColor.systemBlue.cgColor
        favoriteButton.layer.shadowRadius = 2
        favoriteButton.layer.shadowOpacity = 0.5
        favoriteButton.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    private func addActions() {
        favoriteButton.addTarget(self, action: #selector(favoriteButtonPressed), for: .touchUpInside)
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
        dateLabel.autoPinEdge(.trailing, to: .leading, of: favoriteButton, withOffset: -12)
        
        summaryLabel.autoPinEdge(.top, to: .bottom, of: authorLabel, withOffset: 6)
        summaryLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        summaryLabel.autoPinEdge(.trailing, to: .leading, of: favoriteButton, withOffset: -12)
        
        tagsAndTopicLabel.autoPinEdge(.top, to: .bottom, of: summaryLabel, withOffset: 4)
        tagsAndTopicLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        tagsAndTopicLabel.autoPinEdge(.trailing, to: .leading, of: favoriteButton, withOffset: -12)
        tagsAndTopicLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 12)
    }
    
    @objc private func favoriteButtonPressed() {
        guard let article = article else { return }
        delegate?.didTapFavoriteButton(article: article)
        setAnimationForButton()
    }
    
    func configure(article: Article) {
        self.article = article
        
        titleLabel.text = article.title
        authorLabel.text = article.author
        summaryLabel.text = article.summary
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_US_POSIX")
        dateLabel.text = formatter.string(from: article.publishedAt)
        
        var tagText = ""
        tagText += "Topic: \(article.topic)"
        if !article.tags.isEmpty {
            if !tagText.isEmpty { tagText += " | " }
            tagText += "Tags: \(article.tags.joined(separator: ", "))"
        }
        tagsAndTopicLabel.text = tagText
        setImageForButton()
    }
    
    private func setImageForButton() {
        guard let article = article else { return }
        let imageName = FavoritesManager.shared.isFavorite(article) ? "star.fill" : "star"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    private func setAnimationForButton() {
        UIView.animate(withDuration: 0.2, animations: {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            self.setImageForButton()
            
            UIView.animate(withDuration: 0.2) {
                self.favoriteButton.transform = CGAffineTransform.identity
            }
        }
    }
    
}
