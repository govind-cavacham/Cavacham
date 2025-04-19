//
//  CartViewModel.swift
//  Cavacham
//
//  Created by Grok on 14/04/25.
//

import Foundation
import Combine

class CartViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    
    func addToCart(crystal: Crystal, quantity: Int = 1) {
        if let index = cartItems.firstIndex(where: { $0.crystal.id == crystal.id }) {
            cartItems[index].quantity += quantity
        } else {
            cartItems.append(CartItem(id: UUID().uuidString, crystal: crystal, quantity: quantity))
        }
    }
    
    func removeFromCart(itemId: String) {
        cartItems.removeAll { $0.id == itemId }
    }
    
    func updateQuantity(itemId: String, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.id == itemId }) {
            cartItems[index].quantity = max(1, quantity)
        }
    }
    
    var totalPrice: Double {
        cartItems.reduce(0) { $0 + ($1.crystal.price ?? 0.0) * Double($1.quantity) }
    }
}
