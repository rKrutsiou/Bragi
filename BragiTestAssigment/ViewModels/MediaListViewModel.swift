//
//  MediaListViewModel.swift
//  BragiTestAssigment
//
//  Created by Raman Krutsiou on 27/05/2025.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

protocol MediaListViewModelProtocol {
    var genres: BehaviorRelay<[Genre]> { get }
    var items: BehaviorRelay<[MediaItem]> { get }
    var selectedGenre: BehaviorRelay<Genre?> { get }
    var isLoading: BehaviorRelay<Bool> { get }
    var page: BehaviorRelay<Int> { get }
    
    func fetchGenres()
    func fetchItems(for genreId: Int, page: Int)
    func loadNextPage()
    func refresh()
}

final class MediaListViewModel: MediaListViewModelProtocol {
    // MARK: - Public properties
    let genres = BehaviorRelay<[Genre]>(value: [])
    let items = BehaviorRelay<[MediaItem]>(value: [])
    let selectedGenre = BehaviorRelay<Genre?>(value: nil)
    let isLoading = BehaviorRelay<Bool>(value: false)
    let page = BehaviorRelay<Int>(value: 1)
    
    // MARK: - Private properties
    private let disposeBag = DisposeBag()
    private let networkService: NetworkServiceProtocol
    private let mediaType: MediaType
    
    // MARK: - Initialization
    init(networkService: NetworkServiceProtocol, mediaType: MediaType) {
        self.networkService = networkService
        self.mediaType = mediaType
        
        setupBindings()
    }
    
    // MARK: - Private methods
    private func setupBindings() {
        selectedGenre
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] genre in
                self?.fetchItems(for: genre.id, page: 1)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Public methods
    func fetchGenres() {
        isLoading.accept(true)
        
        let genresObservable = mediaType == .movies
            ? networkService.fetchMovieGenres()
            : networkService.fetchTVGenres()
        
        genresObservable
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] genres in
                self?.selectedGenre.accept(genres.first)
            }, onError: { [weak self] _ in
                self?.isLoading.accept(false)
            }, onCompleted: { [weak self] in
                self?.isLoading.accept(false)
            })
            .bind(to: genres)
            .disposed(by: disposeBag)
    }
    
    func fetchItems(for genreId: Int, page: Int) {
        isLoading.accept(true)
        
        let itemsObservable = mediaType == .movies
            ? networkService.discoverMovies(genreId: genreId, page: page)
            : networkService.discoverTV(genreId: genreId, page: page)
        
        itemsObservable
            .flatMap { [weak self] items -> Observable<[MediaItem]> in
                guard let self = self else { return .just([]) }
                
                let detailObservables = items.map { item in
                    self.fetchDetailForItem(item)
                }
                
                return Observable.zip(detailObservables)
            }
            .observe(on: MainScheduler.instance)
            .do(onError: { [weak self] _ in
                self?.isLoading.accept(false)
            }, onCompleted: { [weak self] in
                self?.isLoading.accept(false)
            })
            .subscribe(onNext: { [weak self] items in
                guard let self = self else { return }
                
                if page == 1 {
                    self.items.accept(items)
                } else {
                    self.items.accept(self.items.value + items)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchDetailForItem(_ item: MediaItemResponse) -> Observable<MediaItem> {
        let detailObservable = mediaType == .movies
            ? networkService.fetchMovieDetail(id: item.id)
            : networkService.fetchTVDetail(id: item.id)
        
        return detailObservable.map { details in
            MediaItem(
                id: item.id,
                title: item.title,
                originalTitle: item.originalTitle,
                overview: item.overview,
                posterPath: item.posterPath,
                backdropPath: item.backdropPath,
                releaseDate: item.releaseDate,
                voteAverage: item.voteAverage,
                voteCount: item.voteCount,
                popularity: item.popularity,
                originalLanguage: item.originalLanguage,
                adult: item.adult,
                genreIds: item.genreIds,
                type: item.type,
                video: item.video,
                originCountry: item.originCountry,
                budget: details.budget,
                revenue: details.revenue,
                lastAirDate: details.lastAirDate,
                lastEpisodeToAir: details.lastEpisodeToAir
            )
        }
    }
    
    func loadNextPage() {
        guard let genre = selectedGenre.value else { return }
        let nextPage = page.value + 1
        page.accept(nextPage)
        fetchItems(for: genre.id, page: nextPage)
    }
    
    func refresh() {
        page.accept(1)
        fetchGenres()
    }
}
