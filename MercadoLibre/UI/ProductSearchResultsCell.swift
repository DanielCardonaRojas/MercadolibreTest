//
//  ProductSearchResultsCell.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 26/03/21.
//

import UIKit
import KeypathAutolayout

class ProductSearchResultCell: UICollectionViewCell {
    private var observations = [NSKeyValueObservation]()
    
    lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 2
        return lbl
    }()
    
    func configure(with result: ProductSearchResult) {
        titleLabel.text = result.title
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
        
        NSLayoutConstraint.activate {
            titleLabel.relativeTo(self, positioned: .centered + .equallySized())
        }

    }
    
}
