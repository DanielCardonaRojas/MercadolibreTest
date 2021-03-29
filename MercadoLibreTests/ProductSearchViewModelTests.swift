//
//  ProductSearchViewModelTests.swift
//  MercadoLibreTests
//
//  Created by Daniel Cardona Rojas on 28/03/21.
//

import XCTest
import APIClient

@testable import MercadoLibre

class ProductSearchDelegateSpy: ProductSearchViewModelDelegate {
    var noResultsHandler: ((String) -> Void)?

    func didNotFindResults(for query: String) {
        noResultsHandler?(query)
    }

}

class ProductSearchViewModelTests: XCTestCase {
    var sut: ProductSearchViewModel!
    var mockView: ProductSearchDelegateSpy!
    var mockData: MockDataClientHijacker!

    override func setUp() {
        mockView = ProductSearchDelegateSpy()
        mockData = MockDataClientHijacker()

        sut = ProductSearchViewModel()
        sut.delegate = mockView
        sut.client.hijacker = mockData
    }

    func testCallsDelegatedidNotFindResultsWhenReturnsEmptyResults() {

        // Arrange
        let callsDelegate = XCTestExpectation()

        mockView.noResultsHandler = { _ in
            callsDelegate.fulfill()
        }

        mockData.registerSubstitute(
            SearchResults(siteId: "MCO",
                          paging: PagingParams(total: 1000, offset: 0, limit: 50), results: []),
            requestThatMatches: .any)

        // Act
        sut.search("keyboards", completion: { _ in })

        // Assert

        wait(for: [callsDelegate], timeout: 2.0)

    }

    func testCallsCompletionWithNewItems() {
        let callsCompletionWithNewItems = XCTestExpectation()

        mockData.registerJsonFileContentSubstitute(for: SearchResults.self,
                                                   requestThatMatches: .any,
                                                   bundle: Bundle(for: Self.self),
                                                   fileName: "meli_search_results.json")

        sut.search("keyboards", completion: { newItems in
            if newItems.count == 50 {
                callsCompletionWithNewItems.fulfill()
            }
        })

        wait(for: [callsCompletionWithNewItems], timeout: 3.0)
    }

    func testDoesNotCallAPIForOffsetGreaterThanTotalItemCount() {
        let totalItemCount = 200
        let pageSize = 10
        let doesNotCallCompletion = XCTestExpectation()
        doesNotCallCompletion.isInverted = true

        sut.query = "keyboards"
        sut.pageSize = pageSize
        sut.totalItems = totalItemCount
        sut.offset = totalItemCount - 1

        sut.fetch(completion: { _ in
            doesNotCallCompletion.fulfill()
        })

        wait(for: [doesNotCallCompletion], timeout: 2)

    }

    func testDoesCallAPIIfRemainingItemsAreLessThanPageSize() {
        let totalItemCount = 200
        let pageSize = 10
        let doesNotCallCompletion = XCTestExpectation()

        sut.query = "keyboards"
        sut.pageSize = pageSize
        sut.totalItems = totalItemCount
        sut.offset = totalItemCount - (pageSize / 2)

        let testData = SearchResults(siteId: "MCO",
                                     paging: PagingParams(total: 0, offset: 0, limit: 0),
                                     results: Array(repeating:
                                                        ProductSearchResult(id: "1",
                                                                            title: "test prodcut",
                                                                            price: 2.4, thumbnail: ""),
                                                    count: pageSize / 2))

        mockData.registerSubstitute(testData, requestThatMatches: .any)

        sut.fetch(completion: { _ in
            doesNotCallCompletion.fulfill()
        })

        wait(for: [doesNotCallCompletion], timeout: 2)

    }

}
