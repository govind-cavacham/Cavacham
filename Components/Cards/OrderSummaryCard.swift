//
//  OrderSummaryCard.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct OrderSummaryCard: View {
    let order: Order
    let showTitle: Bool
    
    init(order: Order, showTitle: Bool = true) {
        self.order = order
        self.showTitle = showTitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showTitle {
                Text("Order Summary")
                    .titleMediumStyle()
                    .foregroundColor(.appTextPrimary)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                // Order ID and Date
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Order #\(order.id.prefix(8))")
                            .titleSmallStyle()
                            .foregroundColor(.appTextPrimary)
                        
                        Text(formattedDate(order.createdAt))
                            .labelMediumStyle()
                            .foregroundColor(.appTextSecondary)
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: order.status)
                }
                
                // Payment info
                VStack(alignment: .leading, spacing: 4) {
                    Text("Payment")
                        .titleSmallStyle()
                        .foregroundColor(.appTextPrimary)
                    
                    HStack {
                        Text(order.paymentMethod.displayName)
                            .labelMediumStyle()
                            .foregroundColor(.appTextSecondary)
                        
                        Spacer()
                        
                        Text(order.paymentStatus.rawValue.capitalized)
                            .labelMediumStyle()
                            .foregroundColor(paymentStatusColor)
                    }
                }
                
                Divider()
                
                // Price breakdown
                VStack(spacing: 8) {
                    HStack {
                        Text("Subtotal")
                            .bodyMediumStyle()
                            .foregroundColor(.appTextSecondary)
                        Spacer()
                        Text(formatPrice(order.subtotal))
                            .bodyMediumStyle()
                            .foregroundColor(.appTextSecondary)
                    }
                    
                    HStack {
                        Text("Shipping")
                            .bodyMediumStyle()
                            .foregroundColor(.appTextSecondary)
                        Spacer()
                        Text(formatPrice(order.shippingCost))
                            .bodyMediumStyle()
                            .foregroundColor(.appTextSecondary)
                    }
                    
                    if order.discount > 0 {
                        HStack {
                            Text("Discount")
                                .bodyMediumStyle()
                                .foregroundColor(.appTextSecondary)
                            Spacer()
                            Text("-" + formatPrice(order.discount))
                                .bodyMediumStyle()
                                .foregroundColor(.green)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total")
                            .titleSmallStyle()
                            .foregroundColor(.appTextPrimary)
                        Spacer()
                        Text(formatPrice(order.total))
                            .titleSmallStyle()
                            .foregroundColor(.appTextPrimary)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.appSurface)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Helper Methods
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "Placed on " + formatter.string(from: date)
    }
    
    private func formatPrice(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "₹\(Int(value))"
    }
    
    private var paymentStatusColor: Color {
        switch order.paymentStatus {
        case .completed:
            return .green
        case .pending:
            return .yellow
        case .failed:
            return .red
        case .refunded:
            return .purple
        }
    }
}

struct OrderSummaryCard_Previews: PreviewProvider {
    static var previews: some View {
        let mockOrder = Order(
            id: "ORDER123456789",
            userId: "USER123",
            items: [
                OrderItem(
                    productId: "PROD1",
                    name: "Rose Quartz Crystal",
                    price: 1200,
                    discountedPrice: 1000,
                    imageUrl: "https://example.com/image.jpg",
                    quantity: 2
                )
            ],
            shippingAddress: Address(
                fullName: "John Doe",
                phoneNumber: "+91 9876543210",
                street: "123 Crystal Lane",
                apartment: "Apartment 4B",
                city: "Mumbai",
                state: "Maharashtra",
                zipCode: "400001",
                isDefault: false,
                userId: "USER123"
            ),
            subtotal: 2000,
            shippingCost: 99,
            discount: 200,
            total: 1899,
            status: .processing,
            paymentMethod: .cashOnDelivery,
            paymentStatus: .pending,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        return Group {
            OrderSummaryCard(order: mockOrder)
                .padding()
                .previewDisplayName("With Title")
            
            OrderSummaryCard(order: mockOrder, showTitle: false)
                .padding()
                .previewDisplayName("Without Title")
        }
        .background(Color.appBackground)
        .previewLayout(.sizeThatFits)
    }
} 