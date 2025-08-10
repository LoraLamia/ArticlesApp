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
    
    override func prepareForReuse() {
        topicLabel.text = ""
    }
    
    private func addSubviews() {
        contentView.addSubview(topicLabel)
    }
    
    private func setupConstraints() {
        topicLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        topicLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 8)
        topicLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 8)
        topicLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
    }
    
    private func styleViews() {
        contentView.backgroundColor = .systemBlue
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        
        topicLabel.textColor = .white
        topicLabel.font = .boldSystemFont(ofSize: 14)
        topicLabel.textAlignment = .center
        topicLabel.numberOfLines = 1
    }
    
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
