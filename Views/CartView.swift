//
//  CartView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cartViewModel: CartViewModel
    @EnvironmentObject private var authService: AuthService
    @State private var showCheckout = false
    @State private var showingLogin = false
    let onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void = {}) {
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.edgesIgnoringSafeArea(.all)
                
                if cartViewModel.cartItems.isEmpty {
                    emptyCartView
                } else {
                    VStack(spacing: 0) {
                        // Cart items list
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(cartViewModel.cartItems) { item in
                                    CartItemRow(cartItem: item) { action in
                                        switch action {
                                        case .increase:
                                            cartViewModel.updateQuantity(for: item, quantity: item.quantity + 1)
                                        case .decrease:
                                            cartViewModel.updateQuantity(for: item, quantity: item.quantity - 1)
                                        case .remove:
                                            cartViewModel.removeFromCart(item: item)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 16)
                            
                            // Required spacing for bottom sheet
                            Spacer(minLength: 180)
                        }
                        
                        Spacer()
                    }
                    .overlay(alignment: .bottom) {
                        checkoutBar
                    }
                }
            }
            .navigationTitle("Your Cart")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !cartViewModel.cartItems.isEmpty {
                        Button(action: {
                            cartViewModel.clearCart()
                        }) {
                            Text("Clear")
                                .labelMediumStyle()
                                .foregroundColor(.appTextSecondary)
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showingLogin) {
                LoginView(onLoginSuccess: {
                    showingLogin = false
                    // Show checkout after successful login
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showCheckout = true
                    }
                })
            }
            .background(
                NavigationLink(
                    destination: CheckoutView(cartViewModel: cartViewModel),
                    isActive: $showCheckout
                ) {
                    EmptyView()
                }
            )
        }
    }
    
    // MARK: - Empty Cart
    private var emptyCartView: some View {
        VStack(spacing: 24) {
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundColor(.appSecondary)
            
            Text("Your cart is empty")
                .titleLargeStyle()
                .foregroundColor(.appTextPrimary)
            
            Text("Add some magical crystals to your cart")
                .bodyMediumStyle()
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            AppButton(
                title: "Browse Products",
                icon: "sparkles",
                action: {
                    onDismiss() // Trigger dismissal to navigate to products
                }
            )
            .padding(.top, 16)
        }
    }
    
    // MARK: - Checkout Bar
    private var checkoutBar: some View {
        VStack(spacing: 16) {
            // Divider line
            Rectangle()
                .fill(Color.appTextTertiary.opacity(0.2))
                .frame(height: 1)
            
            // Order summary
            VStack(spacing: 12) {
                HStack {
                    Text("Subtotal")
                        .bodyMediumStyle()
                        .foregroundColor(.appTextSecondary)
                    
                    Spacer()
                    
                    Text("₹\(Int(cartViewModel.subtotal))")
                        .titleMediumStyle()
                        .foregroundColor(.appTextPrimary)
                }
                
                HStack {
                    Text("Shipping")
                        .bodyMediumStyle()
                        .foregroundColor(.appTextSecondary)
                    
                    Spacer()
                    
                    Text("₹99")
                        .bodyMediumStyle()
                        .foregroundColor(.appTextPrimary)
                }
                
                HStack {
                    Text("Total")
                        .titleMediumStyle()
                        .foregroundColor(.appTextPrimary)
                    
                    Spacer()
                    
                    Text("₹\(Int(cartViewModel.subtotal + 99))")
                        .titleLargeStyle()
                        .foregroundColor(.appPrimary)
                }
            }
            
            // Checkout button
            AppButton(
                title: "Proceed to Checkout",
                icon: "creditcard",
                action: {
                    if authService.isAuthenticated {
                        showCheckout = true
                    } else {
                        showingLogin = true
                    }
                },
                isFullWidth: true
            )
        }
        .padding(20)
        .background(Rectangle().fill(Color.appBackground)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5))
    }
}

// MARK: - Helper Views

// Cart Item Row
struct CartItemRow: View {
    let cartItem: CartItem
    let onAction: (CartItemAction) -> Void
    
    enum CartItemAction {
        case increase, decrease, remove
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Product Image
            AsyncImage(url: URL(string: cartItem.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.appSurface)
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                        .shimmering()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                case .failure:
                    Rectangle()
                        .fill(Color.appSurface)
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.appTextTertiary)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 80, height: 80)
            
            // Product Details
            VStack(alignment: .leading, spacing: 4) {
                Text(cartItem.productName)
                    .titleSmallStyle()
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(1)
                
                Text("₹\(Int(cartItem.price))")
                    .labelLargeStyle()
                    .foregroundColor(.appTextPrimary)
                
                // Quantity controls
                HStack(spacing: 8) {
                    Button(action: {
                        onAction(.decrease)
                    }) {
                        Image(systemName: "minus")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                            .padding(6)
                            .background(Color.appSurface)
                            .cornerRadius(4)
                    }
                    
                    Text("\(cartItem.quantity)")
                        .labelMediumStyle()
                        .foregroundColor(.appTextPrimary)
                        .frame(width: 24)
                    
                    Button(action: {
                        onAction(.increase)
                    }) {
                        Image(systemName: "plus")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                            .padding(6)
                            .background(Color.appSurface)
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            // Price and Remove
            VStack(alignment: .trailing, spacing: 8) {
                Text("₹\(Int(cartItem.totalPrice))")
                    .titleSmallStyle()
                    .foregroundColor(.appTextPrimary)
                
                Button(action: {
                    onAction(.remove)
                }) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.appError)
                        .padding(8)
                        .background(Color.appError.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color.appSurface)
        .cornerRadius(16)
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
            .environmentObject(CartViewModel())
            .environmentObject(AuthService())
    }
}
