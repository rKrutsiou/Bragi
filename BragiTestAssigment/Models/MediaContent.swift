//
//  MediaContent.swift
//  BragiTestAssigment
//
//  Created by Raman Krutsiou on 27/05/2025.
//

import Foundation

struct DiscoverResponse: Decodable {
    let page: Int
    let totalResults: Int
    let totalPages: Int
    let results: [MediaItemResponse]
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalResults = "total_results"
        case totalPages = "total_pages"
    }
}

struct MediaItemResponse: Decodable {
    let id: Int
    let title: String
    let originalTitle: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let originalLanguage: String
    let adult: Bool
    let genreIds: [Int]
    let type: MediaType
    let video: Bool?
    let originCountry: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, overview, adult, popularity
        case title, name
        case originalTitle = "original_title"
        case originalName = "original_name"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case originalLanguage = "original_language"
        case genreIds = "genre_ids"
        case video
        case originCountry = "origin_country"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        overview = try container.decode(String.self, forKey: .overview)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath).map { "https://image.tmdb.org/t/p/w500\($0)" }
        backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath)
        voteAverage = try container.decode(Double.self, forKey: .voteAverage)
        voteCount = try container.decode(Int.self, forKey: .voteCount)
        popularity = try container.decode(Double.self, forKey: .popularity)
        originalLanguage = try container.decode(String.self, forKey: .originalLanguage)
        adult = try container.decode(Bool.self, forKey: .adult)
        genreIds = try container.decode([Int].self, forKey: .genreIds)
        
        if let _ = try? container.decode(String.self, forKey: .name) {
            type = .tvShows
            title = try container.decode(String.self, forKey: .name)
            originalTitle = try container.decode(String.self, forKey: .originalName)
            releaseDate = try container.decode(String.self, forKey: .firstAirDate)
            video = nil
            originCountry = try container.decodeIfPresent([String].self, forKey: .originCountry)
        } else {
            type = .movies
            title = try container.decode(String.self, forKey: .title)
            originalTitle = try container.decode(String.self, forKey: .originalTitle)
            releaseDate = try container.decode(String.self, forKey: .releaseDate)
            video = try container.decodeIfPresent(Bool.self, forKey: .video)
            originCountry = nil
        }
    }
}

struct MediaContentDetail: Decodable {
    let type: MediaType
    let budget: Int?
    let revenue: Int?
    let lastAirDate: String?
    let lastEpisodeToAir: LastEpisode?
    
    enum CodingKeys: String, CodingKey {
        case budget
        case revenue
        case lastAirDate = "last_air_date"
        case lastEpisodeToAir = "last_episode_to_air"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let _ = try? container.decode(Int.self, forKey: .budget) {
            type = .movies
            budget = try container.decode(Int.self, forKey: .budget)
            revenue = try container.decode(Int.self, forKey: .revenue)
            lastAirDate = nil
            lastEpisodeToAir = nil
        } else {
            type = .tvShows
            budget = nil
            revenue = nil
            lastAirDate = try container.decode(String.self, forKey: .lastAirDate)
            lastEpisodeToAir = try container.decode(LastEpisode.self, forKey: .lastEpisodeToAir)
        }
    }
}

struct LastEpisode: Decodable {
    let name: String
}


struct MediaItem {
    let id: Int
    let title: String
    let originalTitle: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let originalLanguage: String
    let adult: Bool
    let genreIds: [Int]
    let type: MediaType
    let video: Bool?
    let originCountry: [String]?
    let budget: Int?
    let revenue: Int?
    let lastAirDate: String?
    let lastEpisodeToAir: LastEpisode?
}
