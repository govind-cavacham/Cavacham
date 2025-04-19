//
//  CartItem.swift
//  Cavacham
//
//  Created by Grok on 14/04/25.
//

import Foundation

struct CartItem: Identifiable, Codable {
    let id: String
    let crystal: Crystal
    var quantity: Int
}
