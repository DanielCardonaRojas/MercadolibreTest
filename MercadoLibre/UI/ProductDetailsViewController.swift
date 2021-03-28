//
//  ProductDetailsViewController.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 27/03/21.
//

import SwiftUI
import UIKit
import Auk

class ProductDetailsViewController: UIViewController {

    lazy var viewModel: ProductDetailsViewModel = {
        let vm = ProductDetailsViewModel()
        vm.delegate = self
        return vm

    }()

    @IBOutlet var carouselContainer: UIView!
    @IBOutlet var carouselScrollView: UIScrollView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!

    var itemId: String? {
        didSet {
            if let productId = itemId {
                viewModel.itemId = productId
                viewModel.fetchItem()
            }
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }

    private func setupSubviews() {
        carouselContainer.layer.cornerRadius = 10
        carouselContainer.clipsToBounds = true
        carouselScrollView.auk.settings.contentMode = .scaleAspectFit
        carouselScrollView.auk.settings.placeholderImage = UIImage.mercadolibreLogoGrey
    }
}

extension ProductDetailsViewController: ProductDetailsViewModelDelegate {
    func configure(with product: ProductDetails) {
        if carouselScrollView.auk.numberOfPages == 0 {
            product.pictures.forEach({ picture in
                carouselScrollView.auk.show(url: picture.url)
            })
        }

        titleLabel.text = product.title
        descriptionLabel.text = product.descriptions?.first?.plainText
        priceLabel.text = product.price.currencyFormatted()
    }

}
