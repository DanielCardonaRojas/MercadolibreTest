//
//  Suggestions.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 28/03/21.
//

import Foundation

struct Suggestion: Decodable {
    let suggestedQuery: String

    enum CodingKeys: String, CodingKey {
        case suggestedQuery = "q"
    }
}

struct SearchSuggestions: Decodable {

    let query: String
    let suggestedQueries: [Suggestion]

    enum CodingKeys: String, CodingKey {
        case suggestedQueries = "suggested_queries"
        case query = "q"
    }
}
