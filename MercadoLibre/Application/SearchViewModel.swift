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

    var isLoading: Bool = false
    let pageSize = 7
    
    var products = [ProductSearchResult]()
    
    var query: String? {
        didSet {
            if oldValue != query {
                resetPaging()
            }
        }
    }

    var disposables = Set<AnyCancellable>()
    
    var offset: Int = 0
    var totalItems: Int?

    func search(_ query: String, completion: @escaping () -> Void) {
        self.query = query
        fetch(completion: { _ in completion() })
        
    }
    
    private func addItems(_ newFetchedItems: [ProductSearchResult]) {
        products.append(contentsOf: newFetchedItems)
        offset = products.count - 1
    }
    
    func fetch(completion: @escaping ([ProductSearchResult]) -> Void) {
        guard let searchString = query, !isLoading else {
            return
        }
        
        let limit = pageSize
        
        print("Loading items \(offset) through: \(offset + limit - 1)")
        
        isLoading = true
        client.request(SearchAPI.search(query: searchString, offset: offset, limit: limit))
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
        }, receiveValue: { searchResponse in
            self.totalItems = searchResponse.paging.total
            self.addItems(searchResponse.results)
            completion(searchResponse.results)
        }).store(in: &disposables)
    }


    private func resetPaging() {
        offset = 0
        products = []
        totalItems = nil
    }

}
