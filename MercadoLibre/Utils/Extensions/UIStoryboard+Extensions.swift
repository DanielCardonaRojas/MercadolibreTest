//
//  UIStoryboard+Extensions.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 27/03/21.
//

import UIKit

extension UIStoryboard {
    
    static let main: UIStoryboard = .init(name: "Main", bundle: .main)
    
    /// Instantiates a viewcontroller from the calling storyboard as long as it has an storyboard id equal to class name
    func instantiate<V: UIViewController>(_ viewController: V.Type) -> V? {
        instantiateViewController(withIdentifier: "\(V.self)") as? V
    }

}
