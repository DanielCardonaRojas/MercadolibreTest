//
//  MercadoLibreTests.swift
//  MercadoLibreTests
//
//  Created by Daniel Cardona Rojas on 26/03/21.
//

import XCTest
@testable import MercadoLibre

class MercadoModelLibreTests: XCTestCase {

    func testCanParseSearchResults() {
        let parsed = parseFileNamed("meli_search_results.json", as: SearchResults.self)
        XCTAssert(parsed != nil)
        XCTAssert(!parsed!.results.isEmpty)
    }

    func testCanParseProductDetails() {
        let parsed = parseFileNamed("product_details.json", as: ProductDetails.self)
        XCTAssert(parsed != nil)
        XCTAssert(!parsed!.pictures.isEmpty)
    }

    func parseFileNamed<T: Decodable>(_ fileName: String, as type: T.Type) -> T? {
           let fileBundle = Bundle(for: MercadoModelLibreTests.self)

           guard let url = fileBundle.resourceURL?.appendingPathComponent(fileName) else {
               return nil
           }

           do {
               let data = try Data(contentsOf: URL(fileURLWithPath: url.path))
               let parsed = try JSONDecoder().decode(T.self, from: data)
               return parsed
           } catch let error {
               print(error)
               return nil
           }
       }

}
