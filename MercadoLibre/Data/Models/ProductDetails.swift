//
//  ProductDetails.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 27/03/21.
//

import Foundation

struct ProductDetails: Decodable {
    struct Picture: Decodable {
        let url: String
    }
    
    let title: String
    let price: Double
    let pictures: [Picture]
    
}
