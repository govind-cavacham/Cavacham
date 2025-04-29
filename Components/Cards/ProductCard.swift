//
//  ProductCard.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct ProductCard: View {
    let product: Product
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Product Image
                productImage
                
                // Product Details
                VStack(alignment: .leading, spacing: 4) {
                    // Product Name
                    Text(product.name)
                        .titleSmallStyle()
                        .foregroundColor(.appTextPrimary)
                        .lineLimit(1)
                    
                    // Product Price
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("₹\(Int(product.price))")
                            .labelLargeStyle()
                            .foregroundColor(.appTextPrimary)
                        
                        if product.originalPrice > product.price {
                            Text("₹\(Int(product.originalPrice))")
                                .strikethrough()
                                .labelSmallStyle()
                                .foregroundColor(.appTextTertiary)
                        }
                    }
                    
                    // Product Tags
                    if !product.benefits.isEmpty {
                        HStack {
                            Text(product.benefits[0])
                                .labelSmallStyle()
                                .foregroundColor(.appTextSecondary)
                                .lineLimit(1)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.appSecondary.opacity(0.2))
                                .cornerRadius(4)
                            
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
            }
            .background(Color.appSurface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.appSecondary.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Product image with loading state
    private var productImage: some View {
        ZStack {
            if let imageUrl = product.images.first {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        loadingView
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
                .frame(width: 170, height: 170)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                placeholderImage
            }
            
            // Featured & New badges
            VStack {
                HStack {
                    Spacer()
                    
                    if product.isFeatured {
                        badgeView(text: "Featured", color: .appAccent)
                    }
                }
                
                Spacer()
                
                HStack {
                    if product.isNewLaunch {
                        badgeView(text: "New", color: .appPrimary)
                    }
                    
                    Spacer()
                }
            }
            .padding(8)
        }
        .frame(height: 170)
        .background(Color.appBackground)
        .cornerRadius(12, corners: [.topLeft, .topRight])
    }
    
    // Badge view for features and new items
    private func badgeView(text: String, color: Color) -> some View {
        Text(text)
            .labelSmallStyle()
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(8)
    }
    
    // Loading state
    private var loadingView: some View {
        Rectangle()
            .fill(Color.appSurface)
            .frame(width: 170, height: 170)
            .shimmering()
    }
    
    // Placeholder for failed images
    private var placeholderImage: some View {
        ZStack {
            Rectangle()
                .fill(Color.appSurface)
                .frame(width: 170, height: 170)
            
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(.appTextTertiary)
        }
    }
}

// Preview
struct ProductCard_Previews: PreviewProvider {
    static var previews: some View {
        ProductCard(product: Product.example) {
            print("Product tapped")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

// Shimmer effect for loading
extension View {
    func shimmering() -> some View {
        self.modifier(ShimmerEffect())
    }
}

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: phase - 0.2),
                            .init(color: .white.opacity(0.3), location: phase),
                            .init(color: .clear, location: phase + 0.2)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(content)
                    .blur(radius: 1)
                }
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    self.phase = 1
                }
            }
    }
} 