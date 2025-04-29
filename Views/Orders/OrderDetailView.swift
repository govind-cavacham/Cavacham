//
//  OrderDetailView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct OrderDetailView: View {
    // Environment
    @Environment(\.presentationMode) private var presentationMode
    
    // View model
    @StateObject private var orderViewModel = OrderViewModel()
    
    // Order data
    let order: Order
    
    // View state
    @State private var showingCancelConfirmation = false
    @State private var refreshedOrder: Order?
    @State private var showTrackingView = false
    
    // Get the most updated order data
    private var currentOrder: Order {
        refreshedOrder ?? order
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Order status section
                    orderStatusSection
                    
                    // Order details section
                    orderDetailsSection
                    
                    // Items section
                    itemsSection
                    
                    // Shipping details section
                    shippingSection
                    
                    // Payment details section
                    paymentSection
                    
                    // Actions section
                    actionsSection
                }
                .padding(.horizontal)
                .padding(.vertical, 24)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Order Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
            .onAppear {
                refreshOrder()
            }
            .overlay {
                if orderViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
            .alert(isPresented: $showingCancelConfirmation) {
                Alert(
                    title: Text("Cancel Order"),
                    message: Text("Are you sure you want to cancel this order? This action cannot be undone."),
                    primaryButton: .destructive(Text("Cancel Order")) {
                        cancelOrder()
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showTrackingView) {
                OrderTrackingView(order: currentOrder)
            }
        }
    }
    
    // MARK: - View Components
    
    private var orderStatusSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Order #\(currentOrder.id.prefix(8))")
                    .titleMediumStyle()
                    .foregroundColor(.appTextPrimary)
                
                Spacer()
                
                // Status badge
                StatusBadge(status: currentOrder.status)
            }
            
            HStack {
                Text("Ordered on \(currentOrder.formattedDate)")
                    .bodyMediumStyle()
                    .foregroundColor(.appTextSecondary)
                
                Spacer()
                
                Text("Items: \(currentOrder.items.count)")
                    .bodyMediumStyle()
                    .foregroundColor(.appTextSecondary)
            }
            
            if currentOrder.status != .cancelled {
                OrderProgressView(status: currentOrder.status)
                    .padding(.top, 8)
            }
        }
        .padding(16)
        .background(Color.appSurface)
        .cornerRadius(16)
    }
    
    private var orderDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Order Summary")
                .titleMediumStyle()
                .foregroundColor(.appTextPrimary)
            
            VStack(spacing: 12) {
                summaryRow(title: "Subtotal", value: currentOrder.subtotal)
                summaryRow(title: "Shipping", value: currentOrder.shippingCost)
                
                if currentOrder.discount > 0 {
                    summaryRow(title: "Discount", value: -currentOrder.discount, isDiscount: true)
                }
                
                Divider()
                
                summaryRow(title: "Total", value: currentOrder.total, isTotal: true)
            }
        }
        .padding(16)
        .background(Color.appSurface)
        .cornerRadius(16)
    }
    
    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Items")
                .titleMediumStyle()
                .foregroundColor(.appTextPrimary)
            
            ForEach(currentOrder.items) { item in
                HStack(spacing: 16) {
                    // Item image
                    AsyncImage(url: URL(string: item.imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.appSurface)
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                        case .failure:
                            Rectangle()
                                .fill(Color.appSurface)
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.appTextTertiary)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 60, height: 60)
                    
                    // Item details
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .titleSmallStyle()
                            .foregroundColor(.appTextPrimary)
                        
                        Text("₹\(Int(item.price)) × \(item.quantity)")
                            .bodySmallStyle()
                            .foregroundColor(.appTextSecondary)
                    }
                    
                    Spacer()
                    
                    // Item total
                    Text("₹\(Int(item.totalPrice))")
                        .titleSmallStyle()
                        .foregroundColor(.appTextPrimary)
                }
                
                if item.id != currentOrder.items.last?.id {
                    Divider()
                }
            }
        }
        .padding(16)
        .background(Color.appSurface)
        .cornerRadius(16)
    }
    
    private var shippingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Shipping Address")
                .titleMediumStyle()
                .foregroundColor(.appTextPrimary)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.appTextTertiary)
                        .frame(width: 20)
                    
                    Text(currentOrder.shippingAddress.fullName)
                        .bodyMediumStyle()
                        .foregroundColor(.appTextPrimary)
                }
                
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.appTextTertiary)
                        .frame(width: 20)
                    
                    Text(currentOrder.shippingAddress.phoneNumber ?? "")
                        .bodyMediumStyle()
                        .foregroundColor(.appTextPrimary)
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.appTextTertiary)
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentOrder.shippingAddress.street)
                            .bodyMediumStyle()
                            .foregroundColor(.appTextPrimary)
                        
                        if let apartment = currentOrder.shippingAddress.apartment, !apartment.isEmpty {
                            Text(apartment)
                                .bodyMediumStyle()
                                .foregroundColor(.appTextPrimary)
                        }
                        
                        Text("\(currentOrder.shippingAddress.city), \(currentOrder.shippingAddress.state) \(currentOrder.shippingAddress.zipCode)")
                            .bodyMediumStyle()
                            .foregroundColor(.appTextPrimary)
                        
                        Text("India")
                            .bodyMediumStyle()
                            .foregroundColor(.appTextPrimary)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.appSurface)
        .cornerRadius(16)
    }
    
    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Information")
                .titleMediumStyle()
                .foregroundColor(.appTextPrimary)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: currentOrder.paymentMethod.iconName)
                        .foregroundColor(.appTextTertiary)
                        .frame(width: 20)
                    
                    Text(currentOrder.paymentMethod.displayName)
                        .bodyMediumStyle()
                        .foregroundColor(.appTextPrimary)
                    
                    Spacer()
                    
                    // Payment status
                    paymentStatusBadge
                }
            }
        }
        .padding(16)
        .background(Color.appSurface)
        .cornerRadius(16)
    }
    
    private var actionsSection: some View {
        VStack(spacing: 16) {
            // Cancel order button (show only for pending/processing orders)
            if currentOrder.status == .pending || currentOrder.status == .processing {
                PrimaryButton(
                    title: "Cancel Order",
                    icon: "xmark.circle",
                    action: {
                        showingCancelConfirmation = true
                    }
                )
                .foregroundColor(.red)
            }
            
            // Track order button (show for shipped orders)
            if currentOrder.status == .shipped {
                PrimaryButton(
                    title: "Track Order",
                    icon: "location",
                    action: {
                        showTrackingView = true
                    }
                )
            }
            
            // Contact Support button (always show)
            PrimaryButton(
                title: "Contact Support",
                icon: "bubble.left.and.bubble.right",
                action: {
                    // TODO: Implement contact support
                }
            )
        }
    }
    
    private var paymentStatusBadge: some View {
        let status = currentOrder.paymentStatus
        let color: Color
        
        switch status {
        case .pending:
            color = .yellow
        case .completed:
            color = .green
        case .failed:
            color = .red
        case .refunded:
            color = .purple
        }
        
        return Text(status.rawValue.capitalized)
            .labelSmallStyle()
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(12)
    }
    
    // MARK: - Helper Methods
    
    private func summaryRow(title: String, value: Double, isDiscount: Bool = false, isTotal: Bool = false) -> some View {
        HStack {
            Text(title)
                .if(isTotal) { view in
                    view.titleSmallStyle()
                        .foregroundColor(.appTextPrimary)
                }
                .if(!isTotal) { view in
                    view.bodyMediumStyle()
                        .foregroundColor(.appTextSecondary)
                }
            
            Spacer()
            
            Text(formattedPrice(value, isDiscount: isDiscount))
                .if(isTotal) { view in
                    view.titleSmallStyle()
                        .foregroundColor(.appTextPrimary)
                }
                .if(isDiscount) { view in
                    view.bodyMediumStyle()
                        .foregroundColor(.appEnergy)
                }
                .if(!isTotal && !isDiscount) { view in
                    view.bodyMediumStyle()
                        .foregroundColor(.appTextSecondary)
                }
        }
    }
    
    private func formattedPrice(_ value: Double, isDiscount: Bool = false) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        
        let absValue = abs(value)
        let formattedValue = formatter.string(from: NSNumber(value: absValue)) ?? "₹\(absValue)"
        
        return isDiscount ? "-\(formattedValue)" : formattedValue
    }
    
    // MARK: - Actions
    
    private func refreshOrder() {
        Task {
            do {
                refreshedOrder = try await orderViewModel.loadOrder(id: order.id)
            } catch {
                print("Error refreshing order: \(error)")
            }
        }
    }
    
    private func cancelOrder() {
        Task {
            do {
                try await orderViewModel.cancelOrder(id: currentOrder.id)
                refreshOrder()
            } catch {
                print("Error cancelling order: \(error)")
            }
        }
    }
}

// MARK: - Order Progress View
struct OrderProgressView: View {
    let status: OrderStatus
    
    // Define the steps in order
    private let allSteps: [OrderStatus] = [.pending, .processing, .shipped, .delivered]
    
    var body: some View {
        VStack(spacing: 12) {
            // Progress line
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(Color.appTextTertiary.opacity(0.3))
                    .frame(height: 4)
                
                // Completed part
                Rectangle()
                    .fill(Color.appPrimary)
                    .frame(width: progressWidth, height: 4)
            }
            
            // Step indicators
            HStack(spacing: 0) {
                ForEach(allSteps, id: \.rawValue) { step in
                    Spacer()
                    VStack(spacing: 8) {
                        // Circle indicator
                        Circle()
                            .fill(isCompleted(step) ? Color.appPrimary : Color.appTextTertiary.opacity(0.3))
                            .frame(width: 16, height: 16)
                            .overlay(
                                Group {
                                    if isCompleted(step) {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            )
                        
                        Text(step.displayName)
                            .labelSmallStyle()
                            .foregroundColor(isCompleted(step) ? .appPrimary : .appTextSecondary)
                    }
                    Spacer()
                }
            }
        }
    }
    
    // Determine if a step is completed
    private func isCompleted(_ step: OrderStatus) -> Bool {
        let currentIndex = allSteps.firstIndex(of: status) ?? 0
        let stepIndex = allSteps.firstIndex(of: step) ?? 0
        return stepIndex <= currentIndex
    }
    
    // Calculate progress width
    private var progressWidth: CGFloat {
        if status == .cancelled {
            return 0
        }
        let currentIndex = allSteps.firstIndex(of: status) ?? 0
        let totalSteps = CGFloat(allSteps.count - 1) // Number of segments is steps-1
        return currentIndex == 0 ? 10 : CGFloat(currentIndex) / totalSteps * UIScreen.main.bounds.width
    }
}

// MARK: - View Extension for Conditional Modifiers
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct OrderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock order for preview
        let mockAddress = Address(
            id: UUID().uuidString,
            fullName: "John Doe",
            phoneNumber: "+91 9876543210",
            street: "123 Crystal Lane",
            apartment: "Apartment 4B",
            city: "Mumbai",
            state: "Maharashtra",
            zipCode: "400001",
            isDefault: false,
            userId: "user123"
        )
        
        let mockOrderItems = [
            OrderItem(
                productId: "1",
                name: "Rose Quartz Crystal",
                price: 1200,
                discountedPrice: 1000,
                imageUrl: "https://example.com/image.jpg",
                quantity: 2
            ),
            OrderItem(
                productId: "2",
                name: "Amethyst Crystal",
                price: 1500,
                discountedPrice: 1500,
                imageUrl: "https://example.com/image2.jpg",
                quantity: 1
            )
        ]
        
        let mockOrder = Order(
            id: "ORDER12345",
            userId: "user123",
            items: mockOrderItems,
            shippingAddress: mockAddress,
            subtotal: 3500,
            shippingCost: 99,
            discount: 0,
            total: 3599,
            status: .shipped,
            paymentMethod: .cashOnDelivery,
            paymentStatus: .pending,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        return OrderDetailView(order: mockOrder)
    }
} 