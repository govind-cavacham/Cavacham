//
//  FavoritesViewModel.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favoriteProducts: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firebaseService = FirebaseService()
    private var userId: String? = nil // Will be used when auth is implemented
    
    // Load favorites
    func loadFavoriteProducts() async {
        isLoading = true
        errorMessage = nil
        
        // For now, just load some featured products as fake favorites
        // This will be replaced with actual user favorites when auth is implemented
        do {
            favoriteProducts = try await firebaseService.fetchFeaturedProducts()
        } catch {
            errorMessage = "Failed to load favorites: \(error.localizedDescription)"
            print("Error loading favorites: \(error)")
        }
        
        isLoading = false
    }
    
    // Toggle favorite status
    func toggleFavorite(for product: Product) async {
        // Check if product is already favorited
        if let index = favoriteProducts.firstIndex(where: { $0.id == product.id }) {
            // Remove from favorites
            favoriteProducts.remove(at: index)
        } else {
            // Add to favorites
            favoriteProducts.append(product)
        }
        
        // TODO: Save to Firebase when auth is implemented
    }
    
    // Check if a product is favorited
    func isFavorite(product: Product) -> Bool {
        return favoriteProducts.contains(where: { $0.id == product.id })
    }
} 