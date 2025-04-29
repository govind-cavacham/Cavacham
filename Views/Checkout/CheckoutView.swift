//
//  CheckoutView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct CheckoutView: View {
    // Environment
    @Environment(\.presentationMode) private var presentationMode
    
    // View models
    @ObservedObject var cartViewModel: CartViewModel
    @StateObject private var orderViewModel = OrderViewModel()
    @StateObject private var addressViewModel = AddressViewModel()
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    // State
    @State private var showingAddressSelection = false
    @State private var isPlacingOrder = false
    @State private var selectedAddress: Address?
    @State private var orderPlaced = false
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var currentOrder: Order?
    @State private var showingLogin = false
    @State private var showAddAddress = false
    
    // Computed properties to simplify expressions
    private var shippingCost: Double { 99.0 }
    private var discount: Double { 0.0 }
    private var total: Double { cartViewModel.subtotal + shippingCost - discount }
    private var hasItems: Bool { !cartViewModel.cartItems.isEmpty }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            if orderPlaced, let order = currentOrder {
                // Order success view
                OrderSuccessView(order: order) {
                    // Clear cart and dismiss
                    cartViewModel.clearCart()
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                // Main checkout content
                ScrollView {
                    VStack(spacing: 24) {
                        // Shipping address section
                        addressSection
                        
                        // Payment method section
                        paymentSection
                        
                        // Order summary section
                        orderSummarySection
                    }
                    .padding(.vertical)
                }
                
                // Bottom bar with place order button
                bottomBar
            }
        }
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
        .sheet(isPresented: $showingAddressSelection) {
            NavigationView {
                AddressListView(
                    mode: .selection,
                    onAddressSelected: { address in
                        selectedAddress = address
                        showingAddressSelection = false
                    }
                )
                .environmentObject(authViewModel)
                .environmentObject(addressViewModel)
            }
        }
        .sheet(isPresented: $showingLogin) {
            LoginView(onLoginSuccess: {
                showingLogin = false
                Task {
                    let userId = authViewModel.userId
                    if !userId.isEmpty {
                        await addressViewModel.loadAddresses(userId: userId)
                        if selectedAddress == nil {
                            selectedAddress = addressViewModel.getDefaultAddress()
                        }
                    }
                }
            })
        }
        .sheet(isPresented: $showAddAddress) {
            NavigationView {
                AddAddressView(userId: authViewModel.userId)
                    .environmentObject(authViewModel)
                    .environmentObject(addressViewModel)
            }
        }
        .alert(isPresented: $showingError) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage ?? "An unknown error occurred"),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            // Check for authentication
            if !authService.isAuthenticated {
                // Show login prompt if not logged in
                errorMessage = "You need to be logged in to checkout"
                showingLogin = true
            } else {
                Task {
                    let userId = authViewModel.userId
                    if !userId.isEmpty {
                        await addressViewModel.loadAddresses(userId: userId)
                        if selectedAddress == nil {
                            selectedAddress = addressViewModel.getDefaultAddress()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: "Shipping Address",
                icon: "location.fill"
            )
            
            if let address = selectedAddress {
                // Selected address view
                AddressCard(
                    address: address,
                    isSelected: true,
                    onSelect: nil,
                    onEdit: {
                        addressViewModel.editAddress(address)
                        showAddAddress = true
                    },
                    onDelete: {},
                    onSetDefault: nil
                )
            } else {
                // Address selection button
                Button(action: {
                    showingAddressSelection = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.appPrimary)
                        
                        Text("Select or Add Address")
                            .bodyLargeStyle()
                            .foregroundColor(.appPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.appTextTertiary)
                    }
                    .padding()
                    .background(Color.appSurface)
                    .cornerRadius(16)
                }
            }
            
            Button(action: {
                addressViewModel.addressToEdit = nil // Clear for new address
                showAddAddress = true
            }) {
                Text("Add New Address")
                    .foregroundColor(.appPrimary)
            }
        }
        .padding(.horizontal)
    }
    
    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: "Payment Method",
                icon: "creditcard.fill"
            )
            
            // COD option
            PaymentMethodCard(
                title: "Cash on Delivery",
                description: "Pay when you receive your order",
                icon: "indianrupeesign.circle.fill",
                isSelected: true
            )
            
            // Razorpay - coming soon
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .foregroundColor(.appTextTertiary)
                        .frame(width: 24, height: 24)
                    
                    Text("Razorpay")
                        .titleSmallStyle()
                        .foregroundColor(.appTextTertiary)
                    
                    Spacer()
                    
                    Text("Coming Soon")
                        .labelSmallStyle()
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.appTextTertiary)
                        .cornerRadius(12)
                }
                
                Text("Pay securely with credit/debit cards, UPI, and more")
                    .bodySmallStyle()
                    .foregroundColor(.appTextTertiary)
            }
            .padding()
            .background(Color.appSurface.opacity(0.5))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.appTextTertiary.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
    
    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: "Order Summary",
                icon: "bag.fill"
            )
            
            // Items list
            VStack(spacing: 16) {
                ForEach(cartViewModel.cartItems) { item in
                    CheckoutItemRow(cartItem: item)
                }
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // Price breakdown
            VStack(spacing: 12) {
                PriceSummaryRow(
                    title: "Subtotal",
                    value: cartViewModel.subtotal
                )
                
                PriceSummaryRow(
                    title: "Shipping",
                    value: shippingCost
                )
                
                if discount > 0 {
                    PriceSummaryRow(
                        title: "Discount",
                        value: -discount,
                        isDiscount: true
                    )
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                PriceSummaryRow(
                    title: "Total",
                    value: total,
                    isTotal: true
                )
            }
            .padding()
            .background(Color.appSurface)
            .cornerRadius(16)
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
    
    private var bottomBar: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 12) {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .bodySmallStyle()
                        .foregroundColor(.appError)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                AppButton(
                    title: "Place Order",
                    action: {
                        if selectedAddress != nil && hasItems {
                            placeOrder()
                        } else if selectedAddress == nil {
                            errorMessage = "Please select a shipping address"
                            showingError = true
                        } else {
                            errorMessage = "Your cart is empty"
                            showingError = true
                        }
                    },
                    isLoading: isPlacingOrder
                )
            }
            .padding()
            .background(
                Rectangle()
                    .fill(Color.appBackground)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -4)
            )
        }
    }
    
    // MARK: - Actions
    
    private func placeOrder() {
        guard let address = selectedAddress else {
            errorMessage = "Please select a shipping address"
            showingError = true
            return
        }
        
        guard !cartViewModel.cartItems.isEmpty else {
            errorMessage = "Your cart is empty"
            showingError = true
            return
        }
        
        // Start loading state
        isPlacingOrder = true
        errorMessage = nil
        
        Task {
            do {
                // Create order with COD payment method
                let order = try await orderViewModel.createOrder(
                    items: cartViewModel.cartItems,
                    subtotal: cartViewModel.subtotal,
                    shipping: shippingCost,
                    discount: discount,
                    total: total,
                    shippingAddress: address,
                    paymentMethod: .cashOnDelivery
                )
                
                // Order created successfully
                await MainActor.run {
                    currentOrder = order
                    orderPlaced = true
                    isPlacingOrder = false
                }
            } catch {
                // Handle any errors
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    isPlacingOrder = false
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct CheckoutItemRow: View {
    let cartItem: CartItem
    
    var body: some View {
        HStack(spacing: 16) {
            // Product Image
            AsyncImage(url: URL(string: cartItem.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.appSurface)
                        .frame(width: 60, height: 60)
                        .cornerRadius(12)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .cornerRadius(12)
                case .failure:
                    Rectangle()
                        .fill(Color.appSurface)
                        .frame(width: 60, height: 60)
                        .cornerRadius(12)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.appTextTertiary)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 60, height: 60)
            
            // Product Details
            VStack(alignment: .leading, spacing: 4) {
                Text(cartItem.productName)
                    .titleSmallStyle()
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(1)
                
                Text("₹\(Int(cartItem.price))")
                    .labelLargeStyle()
                    .foregroundColor(.appTextSecondary)
            }
            
            Spacer()
            
            // Quantity and Total
            VStack(alignment: .trailing, spacing: 4) {
                Text("Qty: \(cartItem.quantity)")
                    .labelMediumStyle()
                    .foregroundColor(.appTextSecondary)
                
                Text("₹\(Int(cartItem.totalPrice))")
                    .titleSmallStyle()
                    .foregroundColor(.appTextPrimary)
            }
        }
        .padding()
        .background(Color.appSurface)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct PaymentMethodCard: View {
    let title: String
    let description: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        HStack {
            // Icon
            Image(systemName: icon)
                .foregroundColor(isSelected ? .appPrimary : .appTextSecondary)
                .frame(width: 24, height: 24)
            
            // Title and description
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .titleSmallStyle()
                    .foregroundColor(.appTextPrimary)
                
                Text(description)
                    .bodySmallStyle()
                    .foregroundColor(.appTextSecondary)
            }
            
            Spacer()
            
            // Selection indicator
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.appPrimary)
                    .font(.title3)
            }
        }
        .padding()
        .background(Color.appSurface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isSelected ? Color.appPrimary : Color.clear,
                    lineWidth: isSelected ? 2 : 0
                )
        )
        .padding(.horizontal)
    }
}

struct PriceSummaryRow: View {
    let title: String
    let value: Double
    var isDiscount: Bool = false
    var isTotal: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .style(isTotal: isTotal, isDiscount: false)
            
            Spacer()
            
            Text(formattedPrice)
                .style(isTotal: isTotal, isDiscount: isDiscount)
        }
    }
    
    private var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        
        return formatter.string(from: NSNumber(value: abs(value))) ?? "₹\(Int(abs(value)))"
    }
}

struct OrderSuccessView: View {
    let order: Order
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            // Success animation
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.appSuccess)
                .padding()
            
            VStack(spacing: 16) {
                Text("Order Placed Successfully!")
                    .titleLargeStyle()
                    .foregroundColor(.appTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Thank you for shopping with Cavacham")
                    .bodyLargeStyle()
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 24) {
                // Order details card
                VStack(spacing: 16) {
                    HStack {
                        Text("Order ID")
                            .bodyMediumStyle()
                            .foregroundColor(.appTextSecondary)
                        
                        Spacer()
                        
                        Text(order.id)
                            .bodyMediumStyle()
                            .foregroundColor(.appTextPrimary)
                    }
                    
                    HStack {
                        Text("Order Date")
                            .bodyMediumStyle()
                            .foregroundColor(.appTextSecondary)
                        
                        Spacer()
                        
                        Text(formattedDate(order.createdAt))
                            .bodyMediumStyle()
                            .foregroundColor(.appTextPrimary)
                    }
                    
                    HStack {
                        Text("Total Amount")
                            .bodyMediumStyle()
                            .foregroundColor(.appTextSecondary)
                        
                        Spacer()
                        
                        Text(formattedPrice(order.total))
                            .bodyMediumStyle()
                            .foregroundColor(.appTextPrimary)
                    }
                    
                    HStack {
                        Text("Payment Method")
                            .bodyMediumStyle()
                            .foregroundColor(.appTextSecondary)
                        
                        Spacer()
                        
                        Text(order.paymentMethod.displayName)
                            .bodyMediumStyle()
                            .foregroundColor(.appTextPrimary)
                    }
                }
                .padding()
                .background(Color.appSurface)
                .cornerRadius(16)
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            AppButton(
                title: "Continue Shopping",
                action: onContinue
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .padding(.top, 48)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formattedPrice(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        
        return formatter.string(from: NSNumber(value: value)) ?? "₹\(Int(value))"
    }
}

// MARK: - View Extension for Conditional Styling
extension View {
    @ViewBuilder
    func style(isTotal: Bool, isDiscount: Bool) -> some View {
        if isTotal {
            self
                .titleMediumStyle()
                .foregroundColor(.appTextPrimary)
        } else if isDiscount {
            self
                .bodyLargeStyle()
                .foregroundColor(.appEnergy)
        } else {
            self
                .bodyLargeStyle()
                .foregroundColor(.appTextSecondary)
        }
    }
}

// MARK: - Preview
struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(cartViewModel: CartViewModel())
            .environmentObject(AuthService())
            .environmentObject(AuthViewModel())
    }
}
