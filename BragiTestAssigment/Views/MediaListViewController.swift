//
//  MediaListViewController.swift
//  BragiTestAssigment
//
//  Created by Raman Krutsiou on 27/05/2025.
//

import RxCocoa
import RxSwift
import UIKit

final class MediaListViewController: UIViewController {
    private enum Constants {
        static let defaultOffset: CGFloat = 16.0
        static let genreCollectionHeight: CGFloat = 44.0
        static let paginationTriggerOffset: CGFloat =  200.0
    }
    
    // MARK: Properties
    
    private let viewModel: MediaListViewModel
    private let disposeBag = DisposeBag()
    private var lastSelectedGenreId: Int?
    
    private lazy var genresCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.sectionInset = .init(top: 0,
                                    left: Constants.defaultOffset / 2,
                                    bottom: 0,
                                    right: Constants.defaultOffset / 2)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let сollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        сollection.translatesAutoresizingMaskIntoConstraints = false
        сollection.backgroundColor = .clear
        сollection.showsHorizontalScrollIndicator = false
        return сollection
    }()
    
    private lazy var itemsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = .init(top: Constants.defaultOffset,
                                   left: Constants.defaultOffset,
                                   bottom: Constants.defaultOffset,
                                   right: Constants.defaultOffset)
        
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .systemBackground
        return collection
    }()
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Initialization
    
    init(viewModel: MediaListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchGenres()
    }
}

// MARK: Setup UI

private extension MediaListViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(genresCollectionView)
        view.addSubview(itemsCollectionView)
        
        genresCollectionView.register(GenreCell.self,
                                      forCellWithReuseIdentifier: GenreCell.identifier)
        itemsCollectionView.register(MovieCollectionViewCell.self,
                                     forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        
        itemsCollectionView.refreshControl = refreshControl
        
        NSLayoutConstraint.activate([
            genresCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            genresCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            genresCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            genresCollectionView.heightAnchor.constraint(equalToConstant: Constants.genreCollectionHeight),
            
            itemsCollectionView.topAnchor.constraint(equalTo: genresCollectionView.bottomAnchor),
            itemsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            itemsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: Bind View Model

private extension MediaListViewController {
    func bindViewModel() {
        viewModel.genres
            .bind(to: genresCollectionView.rx.items(
                cellIdentifier: GenreCell.identifier,
                cellType: GenreCell.self)
            ) { [weak self] _, genre, cell in
                guard let self else { return }
                
                cell.configure(with: genre)
                cell.setSelected(genre.id == self.viewModel.selectedGenre.value?.id)
            }.disposed(by: disposeBag)
        
        genresCollectionView.rx.modelSelected(Genre.self)
            .bind(to: viewModel.selectedGenre)
            .disposed(by: disposeBag)
        
        viewModel.selectedGenre
            .skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] selected in
                guard let self = self else { return }
                let genres = self.viewModel.genres.value

                var indexPathsToReload: [IndexPath] = []

                if let lastId = self.lastSelectedGenreId,
                   let lastIndex = genres.firstIndex(where: { $0.id == lastId }) {
                    indexPathsToReload.append(IndexPath(item: lastIndex, section: 0))
                }

                if let new = selected,
                   let newIndex = genres.firstIndex(where: { $0.id == new.id }) {
                    indexPathsToReload.append(IndexPath(item: newIndex, section: 0))
                }

                self.genresCollectionView.reloadItems(at: indexPathsToReload)
                self.lastSelectedGenreId = selected?.id
            })
            .disposed(by: disposeBag)
        
        viewModel.items
            .bind(to: itemsCollectionView.rx.items(
                cellIdentifier: MovieCollectionViewCell.identifier,
                cellType: MovieCollectionViewCell.self)
            ) { _, item, cell in
                cell.configure(with: item)
            }.disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                self.viewModel.refresh()
            }).disposed(by: disposeBag)
        
        viewModel.isLoading
            .skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] loading in
                guard let self else { return }
                
                if !loading {
                    self.refreshControl.endRefreshing()
                }
            }).disposed(by: disposeBag)
        
        itemsCollectionView.rx.contentOffset
            .subscribe(onNext: { [weak self] offset in
                guard let self else { return }
                
                let contentHeight = self.itemsCollectionView.contentSize.height
                let frameHeight = self.itemsCollectionView.frame.size.height
                if offset.y > contentHeight - frameHeight - Constants.paginationTriggerOffset {
                    self.viewModel.loadNextPage()
                }
            }).disposed(by: disposeBag)
    }
}
