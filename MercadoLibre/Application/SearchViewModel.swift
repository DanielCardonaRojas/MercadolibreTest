//
//  SearchViewModel.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 26/03/21.
//

import Foundation
import Combine
import APIClient

class SearchViewModel {
    lazy var client = APIClient(baseURL: URL(string: SearchAPI.baseUrl)!)
    
    func search(_ query: String) -> AnyPublisher<SearchResults, Error> {
        client.request(SearchAPI.search(query: query))
    }

}
