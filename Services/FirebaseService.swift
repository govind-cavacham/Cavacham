//
//  FirebaseService.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import Foundation
import FirebaseFirestore
import Combine

class FirebaseService: ObservableObject {
    private let db = Firestore.firestore()
    
    // Fetch all products
    func fetchProducts() async throws -> [Product] {
        let snapshot = try await db.collection("products").getDocuments()
        return snapshot.documents.map { document in
            Product(id: document.documentID, data: document.data())
        }
    }
    
    // Fetch featured products
    func fetchFeaturedProducts() async throws -> [Product] {
        let snapshot = try await db.collection("products")
            .whereField("isFeatured", isEqualTo: true)
            .getDocuments()
        
        return snapshot.documents.map { document in
            Product(id: document.documentID, data: document.data())
        }
    }
    
    // Fetch products by category
    func fetchProductsByCategory(category: String) async throws -> [Product] {
        let snapshot = try await db.collection("products")
            .whereField("category", isEqualTo: category)
            .getDocuments()
        
        return snapshot.documents.map { document in
            Product(id: document.documentID, data: document.data())
        }
    }
    
    // Fetch product by ID
    func fetchProduct(id: String) async throws -> Product? {
        let document = try await db.collection("products").document(id).getDocument()
        
        guard document.exists, let data = document.data() else {
            return nil
        }
        
        return Product(id: document.documentID, data: data)
    }
    
    // Add more Firebase methods as needed for cart, orders, etc.
} 