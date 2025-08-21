//
//  topicCollectionViewCell.swift
//  ArticlesApp
//
//  Created by Lora Zubic on 08.08.2025..
//

import UIKit
import Foundation
import PureLayout

class TopicCollectionViewCell: UICollectionViewCell {
    
    private let topicLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
        styleViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // should also call super.prepareForReuse()
    override func prepareForReuse() {
        topicLabel.text = ""
    }
    
    private func addSubviews() {
        contentView.addSubview(topicLabel)
    }
    
    private func setupConstraints() {
        // PureLayout is fine, but still this could be simpler:
        // let insets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        // topicLabel.autoPinEdgesToSuperviewMargins(with: insets)

        topicLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        topicLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 8)
        topicLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 8)
        topicLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
    }

    // great
    private func styleViews() {
        contentView.backgroundColor = .systemBlue
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        
        topicLabel.textColor = .white
        topicLabel.font = .boldSystemFont(ofSize: 14)
        topicLabel.textAlignment = .center
        topicLabel.numberOfLines = 1
    }

    // all great, just wanted to mention that for booleans naming is usually starts with `is`: selected -> isSelected
    func configure(topic: String, selected: Bool) {
        topicLabel.text = topic
        
        if !selected {
            contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
            topicLabel.textColor = UIColor.systemBlue
        } else {
            contentView.backgroundColor = .systemBlue
            topicLabel.textColor = .white
        }
    }
    
}
