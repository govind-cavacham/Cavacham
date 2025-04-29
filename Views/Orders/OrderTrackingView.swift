//
//  OrderTrackingView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI
import MapKit

struct OrderTrackingView: View {
    let order: Order
    @StateObject private var viewModel = OrderViewModel()
    @Environment(\.dismiss) private var dismiss
    
    private let statusSteps = OrderStatus.allCases
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Order Status
                orderStatusSection
                
                // Delivery Address
                deliveryAddressSection
                
                // Order Items
                orderItemsSection
                
                // Order Summary
                orderSummarySection
            }
            .padding()
        }
        .navigationTitle("Order #\(order.id.prefix(8))")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Share order details
                    shareOrder()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.appPrimary)
                }
            }
        }
    }
    
    // MARK: - Order Status Section
    private var orderStatusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Order Status",
                icon: "shippingbox.fill"
            )
            
            VStack(spacing: 0) {
                ForEach(Array(statusSteps.enumerated()), id: \.element) { index, status in
                    let isCompleted = isStatusCompleted(status)
                    let isCurrent = order.status == status
                    
                    HStack {
                        // Status indicator
                        Circle()
                            .fill(isCompleted ? Color.appEnergy : Color.appTextTertiary.opacity(0.3))
                            .frame(width: 24, height: 24)
                            .overlay {
                                if isCompleted {
                                    Image(systemName: "checkmark")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(status.displayName)
                                .titleSmallStyle()
                                .foregroundColor(isCurrent ? .appTextPrimary : .appTextSecondary)
                            
                            if isCurrent {
                                Text(getStatusDescription(for: status))
                                    .bodySmallStyle()
                                    .foregroundColor(.appTextTertiary)
                            }
                        }
                        .padding(.leading, 12)
                        
                        Spacer()
                        
                        if isCurrent {
                            Text(order.formattedDate)
                                .labelSmallStyle()
                                .foregroundColor(.appTextTertiary)
                        }
                    }
                    .padding(.vertical, 12)
                    
                    if index < statusSteps.count - 1 {
                        Rectangle()
                            .fill(isCompleted ? Color.appEnergy : Color.appTextTertiary.opacity(0.3))
                            .frame(width: 2, height: 24)
                            .padding(.leading, 11)
                    }
                }
            }
            .padding()
            .background(Color.appSurface)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Delivery Address Section
    private var deliveryAddressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Delivery Address",
                icon: "location.fill"
            )
            
            VStack(alignment: .leading, spacing: 12) {
                // Name
                Text(order.shippingAddress.fullName)
                    .titleSmallStyle()
                    .foregroundColor(.appTextPrimary)
                
                // Phone
                if let phone = order.shippingAddress.phoneNumber {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.appTextTertiary)
                            .font(.footnote)
                        
                        Text(phone)
                            .bodyMediumStyle()
                            .foregroundColor(.appTextSecondary)
                    }
                }
                
                // Address
                HStack(alignment: .top) {
                    Image(systemName: "house.fill")
                        .foregroundColor(.appTextTertiary)
                        .font(.footnote)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(order.shippingAddress.street)
                            .bodyMediumStyle()
                            .foregroundColor(.appTextSecondary)
                        
                        if let apt = order.shippingAddress.apartment {
                            Text(apt)
                                .bodyMediumStyle()
                                .foregroundColor(.appTextSecondary)
                        }
                        
                        Text("\(order.shippingAddress.city), \(order.shippingAddress.state) \(order.shippingAddress.zipCode)")
                            .bodyMediumStyle()
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.appSurface)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Order Items Section
    private var orderItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Order Items",
                icon: "cart.fill"
            )
            
            VStack(spacing: 16) {
                ForEach(order.items) { item in
                    HStack(spacing: 12) {
                        // Product image
                        AsyncImage(url: URL(string: item.imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.appSurface)
                        }
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                        
                        // Product details
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name)
                                .titleSmallStyle()
                                .foregroundColor(.appTextPrimary)
                            
                            Text("Qty: \(item.quantity)")
                                .labelSmallStyle()
                                .foregroundColor(.appTextSecondary)
                            
                            Text("₹\(Int(item.discountedPrice))")
                                .labelLargeStyle()
                                .foregroundColor(.appTextPrimary)
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color.appSurface)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Order Summary Section
    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Order Summary",
                icon: "doc.text.fill"
            )
            
            VStack(spacing: 12) {
                // Subtotal
                PriceLine(
                    title: "Subtotal",
                    amount: order.subtotal
                )
                
                // Shipping
                PriceLine(
                    title: "Shipping",
                    amount: order.shippingCost
                )
                
                // Discount
                if order.discount > 0 {
                    PriceLine(
                        title: "Discount",
                        amount: -order.discount,
                        textColor: .appEnergy
                    )
                }
                
                Divider()
                    .background(Color.appTextTertiary.opacity(0.3))
                    .padding(.vertical, 4)
                
                // Total
                PriceLine(
                    title: "Total",
                    amount: order.total,
                    style: .title
                )
                
                // Payment method
                HStack {
                    Image(systemName: order.paymentMethod.iconName)
                        .foregroundColor(.appTextTertiary)
                    Text(order.paymentMethod.displayName)
                        .labelSmallStyle()
                        .foregroundColor(.appTextSecondary)
                    Spacer()
                    Text(order.paymentStatus.rawValue.capitalized)
                        .labelSmallStyle()
                        .foregroundColor(.appTextSecondary)
                }
                .padding(.top, 8)
            }
            .padding()
            .background(Color.appSurface)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Helper Methods
    private func isStatusCompleted(_ status: OrderStatus) -> Bool {
        let currentIndex = statusSteps.firstIndex(of: order.status) ?? 0
        let statusIndex = statusSteps.firstIndex(of: status) ?? 0
        return statusIndex <= currentIndex
    }
    
    private func getStatusDescription(for status: OrderStatus) -> String {
        switch status {
        case .pending:
            return "Order is being processed"
        case .processing:
            return "Preparing your order"
        case .shipped:
            return "Your order is on the way"
        case .delivered:
            return "Order has been delivered"
        case .cancelled:
            return "Order was cancelled"
        }
    }
    
    private func shareOrder() {
        let text = """
        Order #\(order.id.prefix(8))
        Status: \(order.status.displayName)
        Total Amount: ₹\(Int(order.total))
        """
        
        let av = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(av, animated: true)
        }
    }
}

// MARK: - Supporting Views
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.appPrimary)
            
            Text(title)
                .titleMediumStyle()
                .foregroundColor(.appTextPrimary)
        }
    }
}

struct PriceLine: View {
    let title: String
    let amount: Double
    var textColor: Color = .appTextPrimary
    var style: PriceStyle = .normal
    
    enum PriceStyle {
        case normal
        case title
    }
    
    var body: some View {
        HStack {
            Text(title)
                .if(style == .title) { view in
                    view.titleSmallStyle()
                }
                .if(style == .normal) { view in
                    view.bodyMediumStyle()
                }
                .foregroundColor(textColor)
            
            Spacer()
            
            Text("₹\(Int(amount))")
                .if(style == .title) { view in
                    view.titleSmallStyle()
                }
                .if(style == .normal) { view in
                    view.bodyMediumStyle()
                }
                .foregroundColor(textColor)
        }
    }
}

// MARK: - View Modifier Extension


// MARK: - Supporting Types

struct DeliveryAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct OrderTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock order for preview
        let mockAddress = Address(
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
            )
        ]
        
        let mockOrder = Order(
            id: "ORDER12345",
            userId: "user123",
            items: mockOrderItems,
            shippingAddress: mockAddress,
            subtotal: 2000,
            shippingCost: 99,
            discount: 0,
            total: 2099,
            status: .shipped,
            paymentMethod: .cashOnDelivery,
            paymentStatus: .pending,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        return OrderTrackingView(order: mockOrder)
    }
} 
