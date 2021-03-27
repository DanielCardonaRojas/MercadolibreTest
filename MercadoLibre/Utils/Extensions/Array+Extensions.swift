//
//  Array+Extensions.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 26/03/21.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        guard index < self.count && index >= 0 else {
            return nil
        }
        return self[index]
    }
}
