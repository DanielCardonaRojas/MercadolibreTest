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
    
    struct Description: Decodable {
        let plainText: String
        
        enum CodingKeys: String, CodingKey {
            case plainText = "plain_text"
        }
    }
    
    let title: String
    let price: Double
    let pictures: [Picture]
    
    var descriptions: [Description]? // Gets excluded from coding keys because will be set manually
    
    enum CodingKeys: String, CodingKey {
        case title, price, pictures
        
    }
    
}

