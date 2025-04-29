//
//  ProductViewModel.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import Foundation
import SwiftUI

@MainActor
class ProductViewModel: ObservableObject {
    @Published var allProducts: [Product] = []
    @Published var featuredProducts: [Product] = []
    @Published var productsByCategory: [String: [Product]] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firebaseService = FirebaseService()
    
    // Load featured products
    func loadFeaturedProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            featuredProducts = try await firebaseService.fetchFeaturedProducts()
        } catch {
            errorMessage = "Failed to load featured products: \(error.localizedDescription)"
            print("Error loading featured products: \(error)")
        }
        
        isLoading = false
    }
    
    // Load all products
    func loadAllProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            allProducts = try await firebaseService.fetchProducts()
            
            // Group products by category
            var categorizedProducts: [String: [Product]] = [:]
            for product in allProducts {
                if categorizedProducts[product.category] == nil {
                    categorizedProducts[product.category] = []
                }
                categorizedProducts[product.category]?.append(product)
            }
            productsByCategory = categorizedProducts
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("Error loading products: \(error)")
        }
        
        isLoading = false
    }
    
    // Get products by category
    func loadProductsByCategory(category: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let products = try await firebaseService.fetchProductsByCategory(category: category)
            productsByCategory[category] = products
        } catch {
            errorMessage = "Failed to load \(category) products: \(error.localizedDescription)"
            print("Error loading \(category) products: \(error)")
        }
        
        isLoading = false
    }
    
    // Search products by query
    func searchProducts(query: String) -> [Product] {
        let lowercasedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if lowercasedQuery.isEmpty {
            return []
        }
        
        return allProducts.filter { product in
            // Check name
            if product.name.lowercased().contains(lowercasedQuery) {
                return true
            }
            
            // Check description
            if product.description.lowercased().contains(lowercasedQuery) {
                return true
            }
            
            // Check category
            if product.category.lowercased().contains(lowercasedQuery) {
                return true
            }
            
            // Check search keywords
            if product.searchKeywords.contains(where: { $0.lowercased().contains(lowercasedQuery) }) {
                return true
            }
            
            return false
        }
    }
    
    // Get product by ID
    func getProduct(id: String) async -> Product? {
        do {
            return try await firebaseService.fetchProduct(id: id)
        } catch {
            errorMessage = "Failed to load product: \(error.localizedDescription)"
            print("Error loading product: \(error)")
            return nil
        }
    }
} 