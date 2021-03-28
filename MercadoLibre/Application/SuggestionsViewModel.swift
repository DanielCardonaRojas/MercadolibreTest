//
//  SuggestionsViewModel.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 28/03/21.
//

import Foundation
import APIClient
import Combine

protocol SuggestionsViewModelDelegate: class {
    func didFetchSuggestions(_ suggestions: [Suggestion])
}

class SuggestionsViewModel {
    lazy var client = APIClient(baseURL: URL(string: MercadoLibreAPI.staticContentUrl)!)
    private var disposables = Set<AnyCancellable>()

    weak var delegate: SuggestionsViewModelDelegate?

    var query: String?

    func getSuggestions() {
        guard let searchString = query else {
            return
        }

        let endpoint = MercadoLibreAPI.Suggestions.forQuery(searchString)

        client.request(endpoint)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
        }, receiveValue: { result in
            self.delegate?.didFetchSuggestions(result.suggestedQueries)
        }).store(in: &disposables)

    }
}
