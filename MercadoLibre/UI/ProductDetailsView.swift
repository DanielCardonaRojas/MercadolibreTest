//
//  ProductDetailsView.swift
//  MercadoLibre
//
//  Created by Daniel Cardona Rojas on 27/03/21.
//

import SwiftUI

struct ImageCarousel: View {
    private var numberOfImages = 3

    @State private var currentGalleryIndex = 0
    
    var body: some View {
        TabView {
            ForEach(0..<numberOfImages) { num in
                Image("mbp_\(num + 1)")
                    .resizable()
                    .scaledToFill()
                    .overlay(Color.black.opacity(0.3))
                    .tag(num)
                
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .padding()
    }
}

struct ImageCarousel_Previews: PreviewProvider {
    static var previews: some View {
        ImageCarousel()
    }
}
