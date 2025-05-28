//
//  GenreCell.swift
//  BragiTestAssigment
//
//  Created by Raman Krutsiou on 27/05/2025.
//

import UIKit

final class GenreCell: UICollectionViewCell {
    private enum Constants {
        static let defaultOffset: CGFloat = 16.0
        static let fontSize: CGFloat = 14.0
        static let cornerRadius: CGFloat =  15.0
    }
    
    // MARK: Properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configuration
    
    func configure(with genre: Genre) {
        titleLabel.text = genre.name
    }
    
    func setSelected(_ selected: Bool) {
        contentView.backgroundColor = selected ? .systemBlue : .systemGray
    }
}

// MARK: Setup UI

private extension GenreCell {
     func setupViews() {
        contentView.backgroundColor = .systemGray
        contentView.layer.cornerRadius = Constants.cornerRadius
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.defaultOffset / 2),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.defaultOffset / 2),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.defaultOffset),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.defaultOffset)
        ])
    }
}
