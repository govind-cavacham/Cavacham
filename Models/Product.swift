//
//  Product.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import Foundation
import FirebaseFirestore

struct Product: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var description: String
    var price: Double
    var originalPrice: Double
    var category: String
    var benefits: [String]
    var careInstructions: String
    var energyLevel: Int
    var images: [String]
    var isFeatured: Bool
    var isNewLaunch: Bool
    var chakras: [String]
    var purposes: [String]
    var searchKeywords: [String] = []
    var createdAt: Date
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.name = data["name"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.price = data["price"] as? Double ?? 0.0
        self.originalPrice = data["originalPrice"] as? Double ?? 0.0
        self.category = data["category"] as? String ?? ""
        self.benefits = data["benefits"] as? [String] ?? []
        self.careInstructions = data["careInstructions"] as? String ?? ""
        self.energyLevel = data["energyLevel"] as? Int ?? 0
        self.images = data["images"] as? [String] ?? []
        self.isFeatured = data["isFeatured"] as? Bool ?? false
        self.isNewLaunch = data["isNewLaunch"] as? Bool ?? false
        self.chakras = data["chakras"] as? [String] ?? []
        self.purposes = data["purposes"] as? [String] ?? []
        self.searchKeywords = data["searchKeywords"] as? [String] ?? []
        
        if let timestamp = data["createdAt"] as? Timestamp {
            self.createdAt = timestamp.dateValue()
        } else {
            self.createdAt = Date()
        }
    }
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
}

// For SwiftUI Preview
extension Product {
    static var example: Product {
        Product(
            id: "096F6914-AAE3-46B8-9A15-88A7FE295BE7",
            data: [
                "name": "Citrine",
                "description": "A golden crystal promoting abundance and joy.",
                "price": 899.0,
                "originalPrice": 1199.0,
                "category": "raw",
                "benefits": ["Attracts prosperity", "Boosts confidence", "Enhances positivity"],
                "careInstructions": "Clean with sunlight or sage.",
                "energyLevel": 7,
                "images": ["https://firebasestorage.googleapis.com/product_images/citrine.jpg"],
                "isFeatured": true,
                "isNewLaunch": false,
                "chakras": ["solarPlexus"],
                "purposes": ["money", "career", "health"],
                "searchKeywords": ["citrine", "abundance", "joy"],
                "createdAt": Timestamp(date: Date())
            ]
        )
    }
} 