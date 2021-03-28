//
//  ProductSearchResultsCell.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 26/03/21.
//

import UIKit
import KeypathAutolayout
import SDWebImage

class ProductSearchResultCell: UICollectionViewCell {
    private var observations = [NSKeyValueObservation]()

    lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.numberOfLines = 0
        return lbl
    }()

    lazy var priceLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.boldSystemFont(ofSize: 15)
        lbl.numberOfLines = 1
        lbl.textAlignment = .left
        return lbl

    }()

    lazy var imageView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit
        return img
    }()

    func configure(with result: ProductSearchResult?, index: Int) {
        titleLabel.text = result?.title ?? ""
        priceLabel.text = result.map { $0.price.currencyFormatted() }
        imageView.sd_setImage(with: result.flatMap { URL(string: $0.thumbnail) }, placeholderImage: UIImage(named: "mercadolibre_logo_grey"))
    }

    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(titleLabel)
        addSubview(imageView)
        addSubview(priceLabel)

        NSLayoutConstraint.activate {
            titleLabel.relativeTo(self, positioned: .top() + .right())
            priceLabel.relativeTo(titleLabel, positioned: .left() + .below(spacing: 12) + .width())
            priceLabel.constrainedBy(.constantHeight(20))
            imageView.relativeTo(titleLabel, positioned: .toLeft(spacing: 12))
            imageView.relativeTo(self, positioned: .height() + .left() + .centerY())
            imageView.constrainedBy(.constantWidth(85))
        }

    }

}
