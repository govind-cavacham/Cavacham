//
//  WishlistView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI
import FirebaseFirestore

struct WishlistItem: Identifiable {
    let id: String
    let productId: String
    let name: String
    let price: Double
    let imageURL: String
    let addedDate: Date
}

class WishlistViewModel: ObservableObject {
    @Published var items: [WishlistItem] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    
    func loadWishlist(userId: String) {
        isLoading = true
        
        db.collection("users").document(userId).collection("wishlist")
            .order(by: "addedDate", descending: true)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.showError(message: "Failed to load wishlist: \(error.localizedDescription)")
                    return
                }
                
                self.items = querySnapshot?.documents.compactMap { document in
                    let data = document.data()
                    
                    guard let productId = data["productId"] as? String,
                          let name = data["name"] as? String,
                          let price = data["price"] as? Double,
                          let imageURL = data["imageURL"] as? String,
                          let addedDate = (data["addedDate"] as? Timestamp)?.dateValue()
                    else { return nil }
                    
                    return WishlistItem(
                        id: document.documentID,
                        productId: productId,
                        name: name,
                        price: price,
                        imageURL: imageURL,
                        addedDate: addedDate
                    )
                } ?? []
                
                self.isLoading = false
            }
    }
    
    func removeFromWishlist(userId: String, itemId: String) {
        db.collection("users").document(userId).collection("wishlist")
            .document(itemId).delete { error in
                if let error = error {
                    self.showError(message: "Failed to remove item: \(error.localizedDescription)")
                }
            }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

struct WishlistView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = WishlistViewModel()
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                if viewModel.items.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    wishlistGrid
                }
            }
            .navigationTitle("Wishlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .onAppear {
                viewModel.loadWishlist(userId: authViewModel.userId)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart")
                .font(.system(size: 64))
                .foregroundColor(.appSecondary)
            
            Text("Your Wishlist is Empty")
                .titleMediumStyle()
            
            Text("Save items you love to your wishlist")
                .bodyMediumStyle()
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
    
    private var wishlistGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(viewModel.items) { item in
                    WishlistItemCard(
                        item: item,
                        onRemove: {
                            viewModel.removeFromWishlist(userId: authViewModel.userId, itemId: item.id)
                        }
                    )
                }
            }
            .padding()
        }
    }
}

struct WishlistItemCard: View {
    let item: WishlistItem
    let onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product Image
            AsyncImage(url: URL(string: item.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(height: 180)
            .clipped()
            .cornerRadius(12)
            .overlay(alignment: .topTrailing) {
                Button(action: onRemove) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .padding(8)
                        .background(.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(8)
            }
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .titleSmallStyle()
                    .lineLimit(2)
                
                Text("$\(item.price, specifier: "%.2f")")
                    .titleSmallStyle()
                    .foregroundColor(.appPrimary)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.appSurface)
        .cornerRadius(12)
    }
} 