//
//  MercadoLibreViewModelTests.swift
//  MercadoLibreTests
//
//  Created by Daniel Cardona Rojas on 27/03/21.
//

import XCTest
import APIClient
@testable import MercadoLibre

class ProductDetailsDelegateSpy: ProductDetailsViewModelDelegate {
    var configurationHandler: ((ProductDetails) -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    func configure(with product: ProductDetails) {
        configurationHandler?(product)
    }
    
    func handleFetchError(_ error: Error) {
        errorHandler?(error)
    }
}

class MercadoLibreViewModelTests: XCTestCase {
    var sut: ProductDetailsViewModel! // System under test
    var mockDelegate: ProductDetailsDelegateSpy!

    override func setUp() {
        sut = ProductDetailsViewModel()
        mockDelegate = ProductDetailsDelegateSpy()
        sut.delegate = mockDelegate
        sut.client.hijacker = MockDataClientHijacker.sharedInstance
    }

    func testCallsDelegateWhenSuccessfullyFetchesProductDetails() {
        // Arrange
        let expectation = XCTestExpectation(description: "Call delegate with product")
        
        mockDelegate.configurationHandler = { product in
            let isValidProduct = !product.pictures.isEmpty
            if isValidProduct {
                expectation.fulfill()
            }
        }
        
        MockDataClientHijacker.sharedInstance
         .registerJsonFileContentSubstitute(for: ProductDetails.self,
                                                   requestThatMatches: .any,
                                                   bundle: Bundle(for: Self.self),
                                                   fileName: "product_details.json")
        MockDataClientHijacker.sharedInstance
            .registerSubstitute([
                ProductDetails.Description(plainText: "Test description")
            ], requestThatMatches: .any)

        // Act
        sut.itemId = "1"
        sut.fetchItem()

        // Assert
        
        wait(for: [expectation], timeout: 3.0)

    }
    
    func testCallsDelegateWithErrorWhenFetchingProductDetailsFails() {
        // Arrange
        let expectationDoesNotCallSuccess = XCTestExpectation(description: "Does not call delegate with product")
        expectationDoesNotCallSuccess.isInverted = true
        
        let expectation = XCTestExpectation(description: "Calls delegate with error")
        
        mockDelegate.configurationHandler = { product in
            expectationDoesNotCallSuccess.fulfill()
        }
        
        mockDelegate.errorHandler = { error in
            expectation.fulfill()
        }
        
        MockDataClientHijacker.sharedInstance.registerError("This item does not exist", for: ProductDetails.self, requestThatMatches: .any)

        // Act
        sut.itemId = "1"
        sut.fetchItem()

        // Assert
        wait(for: [expectation, expectationDoesNotCallSuccess], timeout: 3.0)
    }
}
