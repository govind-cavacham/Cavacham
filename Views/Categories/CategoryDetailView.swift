import SwiftUI

struct CategoryDetailView: View {
    let category: Category
    @StateObject private var productViewModel = ProductViewModel()
    @State private var selectedProduct: Product?
    @State private var showProductDetail = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Category header
                VStack(spacing: 12) {
                    AsyncImage(url: URL(string: category.imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.appSurface)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.appTextTertiary)
                            )
                    }
                    .frame(height: 200)
                    .clipped()
                    
                    VStack(spacing: 8) {
                        Text(category.name)
                            .titleLargeStyle()
                            .foregroundColor(.appTextPrimary)
                        
                        Text(category.description)
                            .bodyMediumStyle()
                            .foregroundColor(.appTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                // Products grid
                if productViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding(.top, 32)
                } else if productViewModel.allProducts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 64))
                            .foregroundColor(.gray)
                        Text("No Products Found")
                            .titleMediumStyle()
                        Text("This category has no products yet")
                            .bodyMediumStyle()
                            .foregroundColor(.appTextSecondary)
                    }
                    .padding(.top, 32)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(productViewModel.allProducts) { product in
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
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showProductDetail) {
            if let product = selectedProduct {
                ProductDetailView(product: product)
            }
        }
        .task {
            await productViewModel.loadProductsByCategory(category: category.id)
        }
    }
} 