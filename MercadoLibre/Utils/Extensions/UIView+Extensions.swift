//
//  UIView+Extensions.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 28/03/21.
//

import UIKit

extension UIView {
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = "\(Self.self)"
        let nib = UINib(nibName: nibName, bundle: bundle)
        let views = nib.instantiate(withOwner: self, options: nil)
        return views.first as! UIView
    }

}
