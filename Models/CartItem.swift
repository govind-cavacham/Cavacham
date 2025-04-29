//
//  CartItem.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import Foundation

struct CartItem: Identifiable, Codable, Equatable {
    let id: UUID
    let productId: String
    let productName: String
    let price: Double
    let imageUrl: String
    var quantity: Int
    
    var totalPrice: Double {
        price * Double(quantity)
    }
    
    var product: Product {
        Product(
            id: productId,
            data: [
                "name": productName,
                "description": "",
                "price": price,
                "originalPrice": price,
                "category": "",
                "benefits": [],
                "careInstructions": "",
                "energyLevel": 0,
                "images": [imageUrl],
                "isFeatured": false,
                "isNewLaunch": false,
                "chakras": [],
                "purposes": [],
                "searchKeywords": [],
                "createdAt": Date()
            ]
        )
    }
    
    init(productId: String, productName: String, price: Double, imageUrl: String, quantity: Int) {
        self.id = UUID()
        self.productId = productId
        self.productName = productName
        self.price = price
        self.imageUrl = imageUrl
        self.quantity = quantity
    }
    
    init(id: UUID, productId: String, productName: String, price: Double, imageUrl: String, quantity: Int) {
        self.id = id
        self.productId = productId
        self.productName = productName
        self.price = price
        self.imageUrl = imageUrl
        self.quantity = quantity
    }
    
    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        lhs.id == rhs.id
    }
} 