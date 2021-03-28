//
//  Numeric+Extensions.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 27/03/21.
//

import Foundation

extension Double {
    func currencyFormatted() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        return formatter.string(from: self as NSNumber)!
    }
}
