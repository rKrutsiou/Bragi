//
//  MediaType.swift
//  BragiTestAssigment
//
//  Created by Raman Krutsiou on 27/05/2025.
//

import UIKit

enum MediaType {
    case movies
    case tvShows
    
    var title: String {
        switch self {
        case .movies: return "Movies"
        case .tvShows: return "TV Shows"
        }
    }
    
    var tabBarImage: UIImage? {
        switch self {
        case .movies: return UIImage(systemName: "film")
        case .tvShows: return UIImage(systemName: "tv")
        }
    }
}
