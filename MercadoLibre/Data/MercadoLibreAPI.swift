//
//  SearchAPI.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 26/03/21.
//

import Foundation
import APIClient

enum MercadoLibreAPI {
    static let baseUrl = "https://api.mercadolibre.com"

    enum Search {
        static func find(query: String, offset: Int, limit: Int) -> Endpoint<SearchResults> {
            Endpoint(method: .get, path: "/sites/MCO/search") {
                $0.addQuery("q", value: query)
                    .addQuery("offset", value: "\(offset)")
                    .addQuery("limit", value: "\(limit)")
            }
        }

    }

    enum Products {
        static func getById(_ id: String) -> Endpoint<ProductDetails> {
            Endpoint(method: .get, path: "/items/\(id)")
        }

        static func getDescriptions(_ id: String) -> Endpoint<[ProductDetails.Description]> {
            Endpoint(method: .get, path: "/items/\(id)/descriptions")
        }
    }
}
