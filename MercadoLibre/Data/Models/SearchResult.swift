//
//  SearchResult.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 26/03/21.
//

import Foundation

struct ProductSearchResult: Decodable, Hashable {
    let id: String
    let title: String
    let price: Double
    let thumbnail: String
}

// meli_search_results.json
struct SearchResults: Decodable {
    let siteId: String
    let paging: PagingParams
    let results: [ProductSearchResult]

    enum CodingKeys: String, CodingKey {
        case siteId = "site_id"
        case paging = "paging"
        case results = "results"
    }

}

struct PagingParams: Decodable {
    let total: Int
    let offset: Int
    let limit: Int

}
