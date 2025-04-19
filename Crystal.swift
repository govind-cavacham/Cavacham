//
//  Crystal.swift
//  Cavacham
//
//  Created by Govind Pathak on 12/04/25.
//

import Foundation
import FirebaseFirestore

struct Crystal: Identifiable, Codable {
    var id: String
    var name: String
    var price: Double?
    var description: [String]
    var howToUse: [String]
    var impact: [String]
    var imageURLs: [String]?
    var timestamp: Date?

    enum CodingKeys: String, CodingKey {
        case name, price, description, howToUse, impact, imageURLs, timestamp
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID().uuidString // Temporary ID, will be overwritten in CrystalViewModel
        name = try container.decode(String.self, forKey: .name)
        price = try container.decodeIfPresent(Double.self, forKey: .price)
        description = try container.decode([String].self, forKey: .description)
        howToUse = try container.decode([String].self, forKey: .howToUse)
        impact = try container.decode([String].self, forKey: .impact)
        imageURLs = try container.decodeIfPresent([String].self, forKey: .imageURLs)
        let timestampValue = try container.decodeIfPresent(Timestamp.self, forKey: .timestamp)
        timestamp = timestampValue?.dateValue()
    }

    init(id: String, name: String, price: Double? = nil, description: [String], howToUse: [String], impact: [String], imageURLs: [String]? = nil, timestamp: Date? = nil) {
        self.id = id
        self.name = name
        self.price = price
        self.description = description
        self.howToUse = howToUse
        self.impact = impact
        self.imageURLs = imageURLs
        self.timestamp = timestamp
    }
}

extension Crystal {
    static let allCrystals: [Crystal] = [
        Crystal(
            id: "amethyst",
            name: "Amethyst",
            price: 999.0,
            description: ["Enhances spiritual awareness and intuition."],
            howToUse: ["Place under pillow for better sleep."],
            impact: ["Promotes emotional stability."],
            imageURLs: ["https://example.com/amethyst1.jpg"],
            timestamp: Date()
        )
    ]
}
