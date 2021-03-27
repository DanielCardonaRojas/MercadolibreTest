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
        lbl.numberOfLines = 2
        return lbl
    }()
    
    lazy var imageView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    func configure(with result: ProductSearchResult?, index: Int) {
        titleLabel.text = "\(index)\t" + (result?.title ?? "")
        imageView.sd_setImage(with: result.flatMap { URL(string: $0.thumbnail) }, placeholderImage: UIImage(systemName: "camera"))
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
        
        NSLayoutConstraint.activate {
            titleLabel.relativeTo(self, positioned: .top() + .right())
            imageView.relativeTo(titleLabel, positioned: .toLeft(spacing: 12))
            imageView.relativeTo(self, positioned: .height() + .left() + .centerY())
            imageView.constrainedBy(.constantWidth(70))
        }

    }
    
}
