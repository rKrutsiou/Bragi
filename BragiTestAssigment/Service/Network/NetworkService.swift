//
//  NetworkService.swift
//  BragiTestAssigment
//
//  Created by Raman Krutsiou on 27/05/2025.
//

import Foundation
import RxSwift

protocol NetworkServiceProtocol {
    func fetchMovieGenres() -> Observable<[Genre]>
    func fetchTVGenres() -> Observable<[Genre]>
    func discoverMovies(genreId: Int, page: Int) -> Observable<[MediaItemResponse]>
    func discoverTV(genreId: Int, page: Int) -> Observable<[MediaItemResponse]>
    func fetchMovieDetail(id: Int) -> Observable<MediaContentDetail>
    func fetchTVDetail(id: Int) -> Observable<MediaContentDetail>
}

struct NetworkService: NetworkServiceProtocol {
    private let configuration: NetworkConfiguration
    private let session: URLSession
    
    init(
        configuration: NetworkConfiguration = .test,
        session: URLSession = .shared
    ) {
        self.configuration = configuration
        self.session = session
    }
    
    private func fetch<T: Decodable>(url: URL) -> Observable<T> {
        return Observable.create { observer in
            let task = self.session.dataTask(with: url) { data, response, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.onError(NetworkError.unknown)
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    observer.onError(NetworkError.serverError(httpResponse.statusCode))
                    return
                }
                
                guard let data = data else {
                    observer.onError(NetworkError.noData)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(T.self, from: data)
                    observer.onNext(result)
                    observer.onCompleted()
                } catch {
                    print("Decoding error: \(error)")
                    observer.onError(NetworkError.decodingError)
                }
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func fetchMovieGenres() -> Observable<[Genre]> {
        guard let url = URL(string: "\(configuration.baseURL)/genre/movie/list?api_key=\(configuration.apiKey)&language=en-US") else {
            return Observable.error(NetworkError.invalidURL)
        }
        return fetch(url: url).map { (response: GenreResponse) in response.genres }
    }
    
    func fetchTVGenres() -> Observable<[Genre]> {
        guard let url = URL(string: "\(configuration.baseURL)/genre/tv/list?api_key=\(configuration.apiKey)&language=en-US") else {
            return Observable.error(NetworkError.invalidURL)
        }
        return fetch(url: url).map { (response: GenreResponse) in response.genres }
    }
    
    func discoverMovies(genreId: Int, page: Int) -> Observable<[MediaItemResponse]> {
        guard let url = URL(string: "\(configuration.baseURL)/discover/movie?api_key=\(configuration.apiKey)&with_genres=\(genreId)&page=\(page)&language=en-US&sort_by=popularity.desc") else {
            return Observable.error(NetworkError.invalidURL)
        }
        return fetch(url: url).map { (response: DiscoverResponse) in response.results }
    }
    
    func discoverTV(genreId: Int, page: Int) -> Observable<[MediaItemResponse]> {
        guard let url = URL(string: "\(configuration.baseURL)/discover/tv?api_key=\(configuration.apiKey)&with_genres=\(genreId)&page=\(page)&language=en-US&sort_by=popularity.desc") else {
            return Observable.error(NetworkError.invalidURL)
        }
        return fetch(url: url).map { (response: DiscoverResponse) in response.results }
    }
    
    func fetchMovieDetail(id: Int) -> Observable<MediaContentDetail> {
        guard let url = URL(string: "\(configuration.baseURL)/movie/\(id)?api_key=\(configuration.apiKey)&language=en-US") else {
            return Observable.error(NetworkError.invalidURL)
        }
        return fetch(url: url)
    }
    
    func fetchTVDetail(id: Int) -> Observable<MediaContentDetail> {
        guard let url = URL(string: "\(configuration.baseURL)/tv/\(id)?api_key=\(configuration.apiKey)&language=en-US") else {
            return Observable.error(NetworkError.invalidURL)
        }
        return fetch(url: url)
    }
}
