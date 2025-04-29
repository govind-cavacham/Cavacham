//
//  ProductDetailView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product
    
    @StateObject private var productViewModel = ProductViewModel()
    @EnvironmentObject private var cartViewModel: CartViewModel
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var selectedImageIndex = 0
    @State private var quantity = 1
    @State private var showingAddedToCart = false
    @State private var isAddingToFavorites = false
    @State private var imageLoaded = false
    
    // Animation states
    @State private var animateImage = false
    @State private var animateContent = false
    
    // Cache Manager for images
    private let imageCache = NSCache<NSString, UIImage>()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Product images with carousel
                imageCarousel
                
                // Product Details
                productDetails
                
                Spacer()
            }
        }
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .bottom) {
            bottomBar
        }
        .overlay(alignment: .top) {
            headerOverlay
        }
        .overlay {
            if showingAddedToCart {
                addedToCartOverlay
            }
        }
        .onAppear {
            // Preload images in background
            preloadImages()
            
            // Animate content appearance
            withAnimation(.easeInOut(duration: 0.7).delay(0.3)) {
                animateImage = true
            }
            
            withAnimation(.easeInOut(duration: 0.6).delay(0.5)) {
                animateContent = true
            }
            
            // Load favorites
            Task {
                await favoritesViewModel.loadFavoriteProducts()
            }
        }
    }
    
    // Preload images function
    private func preloadImages() {
        // Only preload the first image immediately
        if let firstImageUrl = product.images.first, let url = URL(string: firstImageUrl) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    // Cache the image
                    self.imageCache.setObject(image, forKey: firstImageUrl as NSString)
                    
                    // Update UI on main thread
                    DispatchQueue.main.async {
                        self.imageLoaded = true
                    }
                }
            }.resume()
        }
        
        // Queue rest of images after a delay
        if product.images.count > 1 {
            DispatchQueue.global(qos: .background).async {
                for i in 1..<product.images.count {
                    if let url = URL(string: product.images[i]) {
                        URLSession.shared.dataTask(with: url) { data, response, error in
                            if let data = data, let image = UIImage(data: data) {
                                self.imageCache.setObject(image, forKey: product.images[i] as NSString)
                            }
                        }.resume()
                    }
                }
            }
        }
    }
    
    // MARK: - Header
    private var headerOverlay: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Button(action: {
                toggleFavorite()
            }) {
                Image(systemName: favoritesViewModel.isFavorite(product: product) ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundColor(favoritesViewModel.isFavorite(product: product) ? .appError : .white)
                    .padding(12)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
                    .overlay(
                        isAddingToFavorites ? ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.6) : nil
                    )
            }
            .disabled(isAddingToFavorites)
        }
        .padding(.horizontal, 20)
        .padding(.top, 48)
    }
    
    // Toggle favorite status
    private func toggleFavorite() {
        isAddingToFavorites = true
        
        Task {
            await favoritesViewModel.toggleFavorite(for: product)
            
            // Add a small delay to make the UI feel more responsive
            try? await Task.sleep(nanoseconds: 500_000_000)
            isAddingToFavorites = false
        }
    }
    
    // MARK: - Image Carousel
    private var imageCarousel: some View {
        ZStack(alignment: .bottom) {
            // Main image
            if let imageUrl = product.images.first {
                GeometryReader { geo in
                    OptimizedAsyncImage(url: URL(string: imageUrl), imageCache: imageCache) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.appSurface)
                                .shimmering()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geo.size.width, height: 400)
                                .clipped()
                                .scaleEffect(animateImage ? 1.0 : 1.1)
                                .opacity(animateImage ? 1.0 : 0.5)
                        case .failure:
                            Rectangle()
                                .fill(Color.appSurface)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.appTextTertiary)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: geo.size.width, height: 400)
                }
                .frame(height: 400)
            } else {
                Rectangle()
                    .fill(Color.appSurface)
                    .frame(height: 400)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.appTextTertiary)
                    )
            }
            
            // Image carousel indicator
            if product.images.count > 1 {
                HStack(spacing: 8) {
                    ForEach(0..<product.images.count, id: \.self) { index in
                        Circle()
                            .fill(index == selectedImageIndex ? Color.white : Color.white.opacity(0.5))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(10)
                .background(Color.black.opacity(0.3))
                .cornerRadius(20)
                .padding(.bottom, 16)
            }
        }
    }
    
    // MARK: - Product Details
    private var productDetails: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Name, price and rating
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(product.category.capitalized)
                        .labelSmallStyle()
                        .foregroundColor(.appTextSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.appSecondary.opacity(0.15))
                        .cornerRadius(20)
                    
                    Spacer()
                    
                    // Energy level indicator
                    HStack(spacing: 4) {
                        Text("Energy")
                            .labelSmallStyle()
                            .foregroundColor(.appTextSecondary)
                        
                        HStack(spacing: 2) {
                            ForEach(1...7, id: \.self) { level in
                                Circle()
                                    .fill(level <= product.energyLevel ? Color.appPrimary : Color.appTextTertiary.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                
                // Name and price
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(product.name)
                            .headingLargeStyle()
                            .foregroundColor(.appTextPrimary)
                        
                        if !product.chakras.isEmpty {
                            Text(product.chakras.joined(separator: ", ").capitalized)
                                .bodyMediumStyle()
                                .foregroundColor(.appTextSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("₹\(Int(product.price))")
                            .titleLargeStyle()
                            .foregroundColor(.appTextPrimary)
                        
                        if product.originalPrice > product.price {
                            Text("₹\(Int(product.originalPrice))")
                                .bodyMediumStyle()
                                .strikethrough()
                                .foregroundColor(.appTextTertiary)
                        }
                    }
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
            }
            
            // Description
            VStack(alignment: .leading, spacing: 12) {
                Text("Description")
                    .titleMediumStyle()
                    .foregroundColor(.appTextPrimary)
                
                Text(product.description)
                    .bodyMediumStyle()
                    .foregroundColor(.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 20)
            
            // Benefits
            if !product.benefits.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Benefits")
                        .titleMediumStyle()
                        .foregroundColor(.appTextPrimary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(product.benefits, id: \.self) { benefit in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.appPrimary)
                                    .font(.system(size: 16))
                                
                                Text(benefit)
                                    .bodyMediumStyle()
                                    .foregroundColor(.appTextSecondary)
                            }
                        }
                    }
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
            }
            
            // Care Instructions
            VStack(alignment: .leading, spacing: 12) {
                Text("Care Instructions")
                    .titleMediumStyle()
                    .foregroundColor(.appTextPrimary)
                
                Text(product.careInstructions)
                    .bodyMediumStyle()
                    .foregroundColor(.appTextSecondary)
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 20)
            
            // Purposes
            if !product.purposes.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Perfect For")
                        .titleMediumStyle()
                        .foregroundColor(.appTextPrimary)
                    
                    HStack(spacing: 8) {
                        ForEach(product.purposes, id: \.self) { purpose in
                            Text(purpose.capitalized)
                                .labelMediumStyle()
                                .foregroundColor(.appTextSecondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.appSecondary.opacity(0.15))
                                .cornerRadius(20)
                        }
                    }
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
            }
            
            // Custom spacing at bottom for bottom bar
            Spacer(minLength: 100)
        }
        .padding(24)
        .background(Color.appBackground)
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .offset(y: -30)
    }
    
    // MARK: - Bottom Bar
    private var bottomBar: some View {
        HStack(spacing: 16) {
            // Quantity selector
            HStack {
                Button(action: {
                    if quantity > 1 {
                        quantity -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.appSurface)
                        .cornerRadius(8)
                }
                
                Text("\(quantity)")
                    .titleSmallStyle()
                    .foregroundColor(.appTextPrimary)
                    .frame(width: 40)
                
                Button(action: {
                    quantity += 1
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.appSurface)
                        .cornerRadius(8)
                }
            }
            
            // Add to cart button
            AppButton(
                title: "Add to Cart",
                icon: "cart.badge.plus",
                action: {
                    // Add to cart
                    for _ in 0..<quantity {
                        cartViewModel.addToCart(product: product)
                    }
                    
                    // Show confirmation
                    withAnimation {
                        showingAddedToCart = true
                    }
                    
                    // Hide confirmation after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showingAddedToCart = false
                        }
                    }
                }, isFullWidth: true
            )
        }
        .padding(20)
        .background(
            Rectangle()
                .fill(Color.appBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
        )
    }
    
    // MARK: - Added to Cart Overlay
    private var addedToCartOverlay: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(.appSuccess)
            
            Text("Added to Cart")
                .titleSmallStyle()
                .foregroundColor(.appTextPrimary)
            
            Spacer()
            
            Button(action: {
                showingAddedToCart = false
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("View Cart")
                    .labelMediumStyle()
                    .foregroundColor(.appPrimary)
            }
        }
        .padding(16)
        .background(Color.appSurface)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 24)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(product: Product.example)
            .environmentObject(CartViewModel())
    }
} 
