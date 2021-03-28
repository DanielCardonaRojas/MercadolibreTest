//
//  SuggestionsViewModelTests.swift
//  MercadoLibreTests
//
//  Created by Daniel Cardona Rojas on 28/03/21.
//

import Foundation
import XCTest
import APIClient
@testable import MercadoLibre

class SuggestionsViewModelDelegateSpy: SuggestionsViewModelDelegate {
    var handleSuggestions: (([Suggestion]) -> Void)?
    func didFetchSuggestions(_ suggestions: [Suggestion]) {
       handleSuggestions?(suggestions)
    }
}

class SuggestionsViewModelTests: XCTestCase {

    var sut: SuggestionsViewModel!
    var mockData: MockDataClientHijacker!
    var mockView: SuggestionsViewModelDelegateSpy!

    override func setUp() {
        mockData = MockDataClientHijacker()
        mockView = SuggestionsViewModelDelegateSpy()

        sut = SuggestionsViewModel()
        sut.client.hijacker = mockData
        sut.delegate = mockView

    }

    func testCallsDelegateWhenFetchesSuggestions() {
        let callsHandleSuggestionsOnView = XCTestExpectation()

        mockView.handleSuggestions = { _ in
            callsHandleSuggestionsOnView.fulfill()

        }

        mockData.registerJsonFileContentSubstitute(for: SearchSuggestions.self,
                                                   requestThatMatches: .any, bundle: Bundle(for: Self.self),
                                                   fileName: "suggested_queries.json")

        sut.query = "shoes"
        sut.getSuggestions()

        wait(for: [callsHandleSuggestionsOnView], timeout: 3.0)

    }
}
