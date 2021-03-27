//
//  SearchAPI.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 26/03/21.
//

import Foundation
import APIClient

enum SearchAPI {
    static let baseUrl = "https://api.mercadolibre.com/sites/MLA"
    
    static func search(query: String, offset: Int, limit: Int) -> Endpoint<SearchResults> {
        Endpoint(method: .get, path: "/search") {
            $0.addQuery("q", value: query)
                .addQuery("offset", value: "\(offset)")
                .addQuery("limit", value: "\(limit)")
        }
    }
    
}
