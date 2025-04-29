//
//  CartViewModel.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class CartViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = [] {
        didSet {
            saveCart()
        }
    }
    
    private let cartKey = "user_cart_items"
    private let db = Firestore.firestore()
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    init() {
        loadCart()
        // Observe auth state changes to reload cart for the appropriate user
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.loadCart()
        }
    }
    
    var totalItems: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    var subtotal: Double {
        cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    // Add product to cart
    func addToCart(product: Product) {
        if let index = cartItems.firstIndex(where: { $0.productId == product.id }) {
            // Product already in cart, increment quantity
            cartItems[index].quantity += 1
            print("📦 Cart: Increased quantity for \(product.name), now: \(cartItems[index].quantity)")
        } else {
            // Add new item to cart
            let imageUrl = product.images.first ?? ""
            let newItem = CartItem(
                productId: product.id,
                productName: product.name,
                price: product.price,
                imageUrl: imageUrl,
                quantity: 1
            )
            cartItems.append(newItem)
            print("📦 Cart: Added new product: \(product.name)")
        }
        
        // Save to UserDefaults and Firestore
        saveCart()
    }
    
    // Update quantity
    func updateQuantity(for item: CartItem, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            if quantity > 0 {
                cartItems[index].quantity = quantity
            } else {
                removeFromCart(item: item)
            }
        }
    }
    
    // Remove from cart
    func removeFromCart(item: CartItem) {
        cartItems.removeAll { $0.id == item.id }
    }
    
    // Clear cart
    func clearCart() {
        cartItems = []
    }
    
    // Save cart to UserDefaults and Firestore
    private func saveCart() {
        // Save to UserDefaults
        do {
            let encoded = try JSONEncoder().encode(cartItems)
            UserDefaults.standard.set(encoded, forKey: cartKey)
            print("📦 Cart: Saved \(cartItems.count) items to UserDefaults")
        } catch {
            print("⚠️ Error saving cart to UserDefaults: \(error.localizedDescription)")
        }
        
        // Save to Firestore if user is authenticated
        saveCartToFirestore()
    }
    
    // Load cart from UserDefaults or Firestore
    private func loadCart() {
        // If user is logged in, try to load from Firestore first
        if userId != nil {
            Task {
                await loadCartFromFirestore()
            }
        } else {
            // Otherwise, load from UserDefaults
            loadCartFromUserDefaults()
        }
    }
    
    // Load cart from UserDefaults
    private func loadCartFromUserDefaults() {
        do {
            if let savedCart = UserDefaults.standard.data(forKey: cartKey) {
                let decodedCart = try JSONDecoder().decode([CartItem].self, from: savedCart)
                DispatchQueue.main.async {
                    self.cartItems = decodedCart
                    print("📦 Cart: Loaded \(self.cartItems.count) items from UserDefaults")
                }
            }
        } catch {
            print("⚠️ Error loading cart from UserDefaults: \(error.localizedDescription)")
            // If there's an error loading the cart, start fresh
            DispatchQueue.main.async {
                self.cartItems = []
                UserDefaults.standard.removeObject(forKey: self.cartKey)
            }
        }
    }
    
    // Save cart to Firestore
    private func saveCartToFirestore() {
        guard let userId = userId else {
            print("📦 Cart: Not saving to Firestore (user not logged in)")
            return
        }
        
        let cartData: [String: Any] = [
            "items": cartItems.map { item in
                return [
                    "id": item.id.uuidString,
                    "productId": item.productId,
                    "productName": item.productName,
                    "price": item.price,
                    "imageUrl": item.imageUrl,
                    "quantity": item.quantity
                ]
            },
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        // Save to users/{userId}/cart instead of cart/{userId}
        db.collection("users").document(userId).collection("cart").document("current").setData(cartData) { error in
            if let error = error {
                print("⚠️ Error saving cart to Firestore: \(error.localizedDescription)")
            } else {
                print("📦 Cart: Successfully saved cart to users/\(userId)/cart")
            }
        }
    }
    
    // Load cart from Firestore
    @MainActor
    private func loadCartFromFirestore() async {
        guard let userId = userId else {
            print("📦 Cart: Not loading from Firestore (user not logged in)")
            loadCartFromUserDefaults()
            return
        }
        
        do {
            // Load from users/{userId}/cart instead of cart/{userId}
            let document = try await db.collection("users").document(userId).collection("cart").document("current").getDocument()
            
            if document.exists, let data = document.data(), let itemsData = data["items"] as? [[String: Any]] {
                var loadedItems: [CartItem] = []
                
                for itemData in itemsData {
                    if let idString = itemData["id"] as? String,
                       let uuid = UUID(uuidString: idString),
                       let productId = itemData["productId"] as? String,
                       let productName = itemData["productName"] as? String,
                       let price = itemData["price"] as? Double,
                       let imageUrl = itemData["imageUrl"] as? String,
                       let quantity = itemData["quantity"] as? Int {
                        
                        let cartItem = CartItem(
                            id: uuid,
                            productId: productId,
                            productName: productName,
                            price: price,
                            imageUrl: imageUrl,
                            quantity: quantity
                        )
                        loadedItems.append(cartItem)
                    }
                }
                
                self.cartItems = loadedItems
                print("📦 Cart: Loaded \(cartItems.count) items from users/\(userId)/cart")
                
                // Also update UserDefaults
                if let encoded = try? JSONEncoder().encode(cartItems) {
                    UserDefaults.standard.set(encoded, forKey: cartKey)
                }
            } else {
                // No cart in Firestore, fall back to UserDefaults
                print("📦 Cart: No cart found in users/\(userId)/cart, checking UserDefaults")
                loadCartFromUserDefaults()
            }
        } catch {
            print("⚠️ Error loading cart from Firestore: \(error.localizedDescription)")
            loadCartFromUserDefaults()
        }
    }
}
