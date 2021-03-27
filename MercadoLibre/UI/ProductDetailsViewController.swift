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

    @IBOutlet var carouselScrollView: UIScrollView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    
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
    }
    
}

extension UIViewController {
    func embedIn<V: UIViewController, C: UIView>(_ vc: V, container: KeyPath<V, C>) {
        vc.addChild(self)
        let containerView = vc[keyPath: container]
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalTo: vc.view.widthAnchor),
            view.heightAnchor.constraint(equalTo: vc.view.heightAnchor),
            view.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            view.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
        ])
        
        didMove(toParent: vc)
        
    }
    func remove() {
        // Just to be safe, we check that this view controller
        // is actually added to a parent before removing it.
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
