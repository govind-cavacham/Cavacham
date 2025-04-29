//
//  SearchView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct SearchView: View {
    // Environment
    @Environment(\.presentationMode) private var presentationMode
    
    // State variables
    @EnvironmentObject private var productViewModel: ProductViewModel
    @EnvironmentObject private var cartViewModel: CartViewModel
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchResults: [Product] = []
    @State private var selectedProduct: Product?
    @State private var showProductDetail = false
    @State private var selectedCategories: Set<String> = []
    
    // Callback for dismissing the view
    var onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void = {}) {
        self.onDismiss = onDismiss
    }
    
    // Categories for filtering
    private let categories = [
        ("all", "All", "square.grid.2x2"),
        ("raw", "Raw", "sparkles"),
        ("jewellery", "Jewellery", "gift"),
        ("home", "Home", "house"),
        ("spiritual", "Spiritual", "heart")
    ]
    
    // Grid layout
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search header
                searchHeader
                
                // Filter categories
                categoryFilters
                
                // Results
                if isSearching {
                    loadingView
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    emptyResultsView
                } else {
                    resultsView
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    await loadProducts()
                }
            }
            .sheet(isPresented: $showProductDetail) {
                if let product = selectedProduct {
                    ProductDetailView(product: product)
                }
            }
        }
    }
    
    // MARK: - UI Components
    
    private var searchHeader: some View {
        HStack(spacing: 16) {
            // Back button
            Button(action: {
                onDismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.appTextSecondary)
            }
            
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.appTextTertiary)
                
                TextField("Search crystals, jewelry...", text: $searchText)
                    .bodyMediumStyle()
                    .foregroundColor(.appTextPrimary)
                    .onChange(of: searchText) { _ in
                        performSearch()
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        performSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.appTextTertiary)
                    }
                }
            }
            .padding(12)
            .background(Color.appSurface)
            .cornerRadius(12)
        }
        .padding()
        .background(Color.appBackground)
    }
    
    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.0) { category in
                    categoryFilterButton(id: category.0, name: category.1, icon: category.2)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color.appBackground)
    }
    
    private func categoryFilterButton(id: String, name: String, icon: String) -> some View {
        let isSelected = selectedCategories.contains(id) || (id == "all" && selectedCategories.isEmpty)
        
        return Button(action: {
            toggleCategory(id)
            performSearch()
        }) {
            HStack(spacing: 6) {
                if id != "all" {
                    Image(systemName: icon)
                        .font(.footnote)
                }
                
                Text(name)
                    .labelMediumStyle()
            }
            .foregroundColor(isSelected ? .white : .appTextSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.appPrimary : Color.appSurface)
            )
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("Searching...")
                .bodyLargeStyle()
                .foregroundColor(.appTextSecondary)
            Spacer()
        }
    }
    
    private var emptyResultsView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.appTextTertiary)
            
            Text("No results found")
                .headingMediumStyle()
                .foregroundColor(.appTextPrimary)
            
            Text("Try different keywords or browse categories")
                .bodyMediumStyle()
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    private var resultsView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(searchResults) { product in
                    ProductCard(product: product) {
                        selectedProduct = product
                        showProductDetail = true
                    }
                }
            }
            .padding()
            .animation(.easeInOut, value: searchResults)
        }
    }
    
    // MARK: - Logic
    
    private func loadProducts() async {
        isSearching = true
        await productViewModel.loadAllProducts()
        
        // Initial search results show all products
        searchResults = productViewModel.allProducts
        isSearching = false
    }
    
    private func performSearch() {
        // Don't search if products haven't loaded yet
        guard !productViewModel.allProducts.isEmpty else {
            return
        }
        
        isSearching = true
        
        // Create a slight delay to prevent rapid searching while typing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Apply search and category filters
            if query.isEmpty && selectedCategories.isEmpty {
                // Show all products when no search or filters
                searchResults = productViewModel.allProducts
            } else {
                var filteredProducts = query.isEmpty ?
                    productViewModel.allProducts :
                    productViewModel.searchProducts(query: query)
                
                // Apply category filters if any are selected
                if !selectedCategories.isEmpty {
                    filteredProducts = filteredProducts.filter { product in
                        selectedCategories.contains(product.category)
                    }
                }
                
                searchResults = filteredProducts
            }
            
            isSearching = false
        }
    }
    
    private func toggleCategory(_ category: String) {
        // If "all" is selected, clear other selections
        if category == "all" {
            selectedCategories.removeAll()
            return
        }
        
        // Toggle the selected category
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}

// MARK: - Previews
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(onDismiss: {})
            .environmentObject(ProductViewModel())
            .environmentObject(CartViewModel())
    }
}
