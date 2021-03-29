//
//  ProductDetailsViewModel.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 27/03/21.
//

import Foundation
import Combine
import APIClient

protocol ProductDetailsViewModelDelegate: class {
    func configure(with product: ProductDetails)
    func handleFetchError(_ error: Error)
}

extension ProductDetailsViewModelDelegate {
    func handleFetchError(_ error: Error) { }
}

class ProductDetailsViewModel {

    lazy var client = APIClient(baseURL: URL(string: MercadoLibreAPI.baseUrl)!)
    private var disposables = Set<AnyCancellable>()
    weak var delegate: ProductDetailsViewModelDelegate?

    var itemId: String?

    /// Fetches the product details for the associated property `itemId` of this class
    func fetchItem() {
        guard let productId = itemId else {
            return
        }

        let endpoint = MercadoLibreAPI.Products.getById(productId)
        let descriptionsEndpoint = MercadoLibreAPI.Products.getDescriptions(productId)

        APIClientPublisher(client: client, endpoint: endpoint)
            .chain({ (productDetail: ProductDetails) -> Endpoint<ProductDetails> in
                return descriptionsEndpoint.map({ descriptions in
                    var productDetailWithDescriptions = productDetail
                    productDetailWithDescriptions.descriptions = descriptions
                    return productDetailWithDescriptions
                })
            })
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { complete in
                print("Complete \(complete)")
                if case .failure(let error) = complete {
                    self.delegate?.handleFetchError(error)
                }

            }, receiveValue: { product in
                self.delegate?.configure(with: product)

            }).store(in: &disposables)
    }

}
