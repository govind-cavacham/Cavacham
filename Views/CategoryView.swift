//
//  CategoryView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

enum CategoryFilter {
    case all
    case newArrivals
    case popular
}

struct CategoryView: View {
    @StateObject private var productViewModel = ProductViewModel()
    @State private var selectedCategory = "all"
    @State private var isLoading = false
    @State private var selectedProduct: Product?
    @State private var showProductDetail = false
    
    let filter: CategoryFilter
    let category: Category?
    
    init(filter: CategoryFilter = .all, category: Category? = nil) {
        self.filter = filter
        self.category = category
        
        if let category = category {
            _selectedCategory = State(initialValue: category.id)
        }
    }
    
    // Categories
    private let categories = [
        ("all", "All", "square.grid.2x2"),
        ("raw", "Raw", "sparkles"),
        ("jewellery", "Jewellery", "gift"),
        ("home", "Home", "house"),
        ("spiritual", "Spiritual", "heart")
    ]
    
    // Grid layout configuration
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if category == nil {
                    // Categories tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(categories, id: \.0) { category in
                                categoryTab(id: category.0, name: category.1, icon: category.2)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .background(Color.appSurface)
                }
                
                // Products grid
                ScrollView {
                    if isLoading {
                        productsLoadingView
                    } else {
                        productsGridView
                    }
                }
                .background(Color.appBackground)
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showProductDetail, content: {
                if let product = selectedProduct {
                    ProductDetailView(product: product)
                }
            })
            .onAppear {
                Task {
                    await loadProducts()
                }
            }
        }
    }
    
    private var navigationTitle: String {
        if let category = category {
            return category.name
        }
        switch filter {
        case .all:
            return "Categories"
        case .newArrivals:
            return "New Arrivals"
        case .popular:
            return "Popular"
        }
    }
    
    // MARK: - Category Tab
    private func categoryTab(id: String, name: String, icon: String) -> some View {
        Button(action: {
            selectedCategory = id
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.body)
                
                Text(name)
                    .labelMediumStyle()
            }
            .foregroundColor(selectedCategory == id ? .appPrimary : .appTextSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(selectedCategory == id ? Color.appPrimary.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(selectedCategory == id ? Color.appPrimary.opacity(0.2) : Color.clear, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Products Grid
    private var productsGridView: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(filteredProducts) { product in
                ProductCard(product: product) {
                    navigateToProduct(product)
                }
            }
        }
        .padding()
        .animation(.easeInOut, value: selectedCategory)
    }
    
    // MARK: - Loading View
    private var productsLoadingView: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(0..<6, id: \.self) { _ in
                Rectangle()
                    .fill(Color.appSurface)
                    .frame(height: 240)
                    .cornerRadius(16)
                    .shimmering()
            }
        }
        .padding()
    }
    
    // MARK: - Helper Methods
    private var filteredProducts: [Product] {
        var products = productViewModel.allProducts
        
        // Apply category filter
        if let category = category {
            products = products.filter { $0.category == category.id }
        } else if selectedCategory != "all" {
            products = products.filter { $0.category == selectedCategory }
        }
        
        // Apply special filters
        switch filter {
        case .newArrivals:
            return products.filter { $0.isNewLaunch }
        case .popular:
            return products.filter { $0.isFeatured }
        case .all:
            return products
        }
    }
    
    private func navigateToProduct(_ product: Product) {
        selectedProduct = product
        showProductDetail = true
    }
    
    private func loadProducts() async {
        isLoading = true
        await productViewModel.loadAllProducts()
        isLoading = false
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView()
    }
} 