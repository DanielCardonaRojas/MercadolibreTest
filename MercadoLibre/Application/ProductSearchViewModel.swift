//
//  SearchViewModel.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 26/03/21.
//

import Foundation
import Combine
import APIClient

protocol ProductSearchViewModelDelegate: class {
    func didNotFindResults(for query: String)
}

class ProductSearchViewModel {
    lazy var client = APIClient(baseURL: URL(string: MercadoLibreAPI.baseUrl)!)

    weak var delegate: ProductSearchViewModelDelegate?

    var isLoading: Bool = false
    var pageSize = 30

    var products = [ProductSearchResult]()

    var query: String? {
        didSet {
            if oldValue != query, oldValue != nil {
                resetPaging()
            }
        }
    }

    /// The remaining items on the server
    var remainingItems: Int? {
        totalItems.map({ $0 - offset - 1})
    }

    private var disposables = Set<AnyCancellable>()

    var offset: Int = 0
    var totalItems: Int?

    /**
            Perfoms a fresh search, clearing out previous results
            - Parameter completion: A closure receiving the new items fetched
     
     */
    func search(_ search: String, completion: @escaping ([ProductSearchResult]) -> Void) {
        let isNewQuery = query.map { $0 != search } ?? true

        guard isNewQuery else {
            completion([])
            return
        }

        query = search
        fetch(completion: completion)

    }

    /**
        Fetches next page of items
     
        - Parameter completion: A closure that receiving the new items fetched
     
     */
    func fetch(completion: @escaping ([ProductSearchResult]) -> Void) {
        guard let searchString = query, !isLoading else {
            return
        }

        var limit = pageSize

        if let remaining = remainingItems {
            limit = remaining > pageSize ? pageSize : remaining
            if remaining <= 0 {
                return
            }

        }

        print("Loading items \(offset) through: \(offset + limit - 1)")

        isLoading = true

        let endpoint = MercadoLibreAPI.Search.find(query: searchString, offset: offset, limit: limit)

        client.request(endpoint)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
                self.isLoading = false
        }, receiveValue: { searchResponse in
            self.totalItems = searchResponse.paging.total
            self.addItems(searchResponse.results)
            if searchResponse.results.isEmpty {
                self.delegate?.didNotFindResults(for: searchString)
            }
            completion(searchResponse.results)
        }).store(in: &disposables)
    }

    private func resetPaging() {
        offset = 0
        products = []
        totalItems = nil
    }
    
    private func addItems(_ newFetchedItems: [ProductSearchResult]) {
        products.append(contentsOf: newFetchedItems)
        offset = products.count - 1
    }


}
