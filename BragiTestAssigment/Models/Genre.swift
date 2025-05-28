//
//  Genre.swift
//  BragiTestAssigment
//
//  Created by Raman Krutsiou on 27/05/2025.
//

import Foundation

struct Genre: Decodable {
    let id: Int
    let name: String
}

struct GenreResponse: Decodable {
    let genres: [Genre]
}
