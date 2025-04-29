//
//  HomeView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var productViewModel: ProductViewModel
    @EnvironmentObject private var categoryViewModel: CategoryViewModel
    @EnvironmentObject private var cartViewModel: CartViewModel
    @State private var selectedProduct: Product?
    @State private var showProductDetail = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            if authViewModel.userId.isEmpty {
                Text("Please log in to view content.")
                    .font(.title2)
                    .padding()
            } else {
                ScrollView {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.2)
                            .padding()
                    } else if let error = errorMessage {
                        VStack(spacing: 16) {
                            Text("Error")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(error)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            Button(action: {
                                Task {
                                    await loadData()
                                }
                            }, label: {
                                Text("Retry")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            })
                        }
                        .padding()
                    } else {
                        VStack(spacing: 24) {
                            // Featured section
                            if !productViewModel.featuredProducts.isEmpty {
                                featuredSection
                            } else {
                                Text("No featured products available")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            }
                            
                            // Categories section
                            if !categoryViewModel.categories.isEmpty {
                                categoriesSection
                            } else {
                                Text("No categories available")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            }
                            
                            // New arrivals section
                            if !productViewModel.allProducts.filter({ $0.isNewLaunch }).isEmpty {
                                newArrivalsSection
                            } else {
                                Text("No new arrivals available")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            }
                            
                            // Popular products section
                            if !productViewModel.allProducts.filter({ $0.isFeatured }).isEmpty {
                                popularProductsSection
                            } else {
                                Text("No popular products available")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.bottom)
                    }
                }
                .navigationTitle("Discover")
                .refreshable {
                    await loadData()
                }
            }
        }
        .sheet(isPresented: $showProductDetail) {
            if let product = selectedProduct {
                ProductDetailView(product: product)
            }
        }
        .task {
            await loadData()
        }
    }
    
    private func loadData() async {
        isLoading = true
        errorMessage = nil
        print("Loading data for HomeView")
        do {
            await productViewModel.loadAllProducts()
            await productViewModel.loadFeaturedProducts()
            await categoryViewModel.loadCategories()
            print("Loaded \(productViewModel.allProducts.count) products, \(productViewModel.featuredProducts.count) featured products, \(categoryViewModel.categories.count) categories")
        } catch {
            errorMessage = "Failed to load data: \(error.localizedDescription)"
            print("Error loading data: \(error)")
        }
        isLoading = false
    }
    
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Featured")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(productViewModel.featuredProducts) { product in
                        ProductCard(product: product) {
                            selectedProduct = product
                            showProductDetail = true
                        }
                        .frame(width: 200)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Categories")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink {
                    CategoryView(filter: .all)
                } label: {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(.appPrimary)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(categoryViewModel.categories) { category in
                        NavigationLink {
                            CategoryView(filter: .all, category: category)
                        } label: {
                            CategoryCard(category: category)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var newArrivalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("New Arrivals")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink {
                    CategoryView(filter: .newArrivals)
                } label: {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(.appPrimary)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(productViewModel.allProducts.filter { $0.isNewLaunch }) { product in
                        ProductCard(product: product) {
                            selectedProduct = product
                            showProductDetail = true
                        }
                        .frame(width: 200)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var popularProductsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Popular")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink {
                    CategoryView(filter: .popular)
                } label: {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(.appPrimary)
                }
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(productViewModel.allProducts.filter { $0.isFeatured }) { product in
                    ProductCard(product: product) {
                        selectedProduct = product
                        showProductDetail = true
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(ProductViewModel())
        .environmentObject(CategoryViewModel())
        .environmentObject(CartViewModel())
}
