//
//  MovieCollectionViewCell.swift
//  BragiTestAssigment
//
//  Created by Raman Krutsiou on 27/05/2025.
//

import UIKit
import Kingfisher

protocol MediaCollectionViewCell: UICollectionViewCell {
    func configure(with item: MediaItem)
}

final class MovieCollectionViewCell: UICollectionViewCell, MediaCollectionViewCell {
    private enum Constants {
        static let defaultOffset: CGFloat = 8.0
        static let fontSize: CGFloat = 14.0
        static let cornerRadius: CGFloat =  8.0
        static let posterImageWidth = (UIScreen.main.bounds.width - 48) / 2
        static let posterImageHeightMultiplier: CGFloat = 1.5
    }
    
    // MARK: - Properties
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.2
        view.clipsToBounds = false
        return view
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    private let budgetLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
        
    private let revenueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .medium)
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .medium)
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
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
    
    // MARK: - Configuration
    
    func configure(with item: MediaItem) {
        if let posterPath = item.posterPath,
           let url = URL(string: posterPath) {
            posterImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "film"),
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]
            )
        } else {
            posterImageView.image = UIImage(systemName: "film")
        }
        
        titleLabel.text = item.title
        ratingLabel.text = "★ \(String(format: "%.1f", item.voteAverage))"
        
        switch item.type {
        case .movies:
            guard let revenue = item.revenue, let budget = item.budget else { return }
            revenueLabel.text = "Revenue: \(revenue.formatNumber())"
            budgetLabel.text = "Budget: \(budget.formatNumber())"
        case .tvShows:
            guard let lastAirDate = item.lastAirDate, let lastEpisodeToAir = item.lastEpisodeToAir?.name else { return }
            revenueLabel.text = "Last air date: \(lastAirDate)"
            budgetLabel.text = "Last episode: \(lastEpisodeToAir)"
        }
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = nil
        titleLabel.text = nil
        ratingLabel.text = nil
    }
}

// MARK: Setup UI

private extension MovieCollectionViewCell {
    func setupViews() {
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        [posterImageView, titleLabel, ratingLabel, budgetLabel, revenueLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            posterImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            posterImageView.widthAnchor.constraint(equalToConstant: Constants.posterImageWidth),
            posterImageView.heightAnchor.constraint(equalToConstant: Constants.posterImageWidth * Constants.posterImageHeightMultiplier),
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: Constants.defaultOffset),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.defaultOffset),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.defaultOffset),
            
            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.defaultOffset / 2),
            ratingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.defaultOffset),
            ratingLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.defaultOffset),
            ratingLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -Constants.defaultOffset),
            
            budgetLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: Constants.defaultOffset / 2),
            budgetLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.defaultOffset),
            budgetLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.defaultOffset),
            
            revenueLabel.topAnchor.constraint(equalTo: budgetLabel.bottomAnchor, constant: Constants.defaultOffset / 2),
            revenueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.defaultOffset),
            revenueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.defaultOffset),
            revenueLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -Constants.defaultOffset)
        ])
    }
}
