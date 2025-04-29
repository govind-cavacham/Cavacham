//
//  Order.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import Foundation
import FirebaseFirestore

enum OrderStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case processing = "processing"
    case shipped = "shipped"
    case delivered = "delivered"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .processing: return "Processing"
        case .shipped: return "Shipped"
        case .delivered: return "Delivered"
        case .cancelled: return "Cancelled"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "yellow"
        case .processing: return "blue"
        case .shipped: return "purple"
        case .delivered: return "green"
        case .cancelled: return "red"
        }
    }
}

enum PaymentMethod: String, Codable, CaseIterable {
    case creditCard = "creditCard"
    case debitCard = "debitCard"
    case upi = "upi"
    case cashOnDelivery = "cashOnDelivery"
    
    var displayName: String {
        switch self {
        case .creditCard: return "Credit Card"
        case .debitCard: return "Debit Card"
        case .upi: return "UPI"
        case .cashOnDelivery: return "Cash on Delivery"
        }
    }
    
    var iconName: String {
        switch self {
        case .creditCard: return "creditcard"
        case .debitCard: return "creditcard.fill"
        case .upi: return "indianrupeesign"
        case .cashOnDelivery: return "banknote"
        }
    }
}

enum PaymentStatus: String, Codable {
    case pending = "pending"
    case completed = "completed"
    case failed = "failed"
    case refunded = "refunded"
}

struct OrderItem: Identifiable, Codable {
    var id: String { productId }
    let productId: String
    let name: String
    let price: Double
    let discountedPrice: Double
    let imageUrl: String
    let quantity: Int
    
    var totalPrice: Double {
        discountedPrice * Double(quantity)
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "productId": productId,
            "name": name,
            "price": price,
            "discountedPrice": discountedPrice,
            "imageUrl": imageUrl,
            "quantity": quantity
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> OrderItem? {
        guard
            let productId = dict["productId"] as? String,
            let name = dict["name"] as? String,
            let price = dict["price"] as? Double,
            let discountedPrice = dict["discountedPrice"] as? Double,
            let imageUrl = dict["imageUrl"] as? String,
            let quantity = dict["quantity"] as? Int
        else { return nil }
        
        return OrderItem(
            productId: productId,
            name: name,
            price: price,
            discountedPrice: discountedPrice,
            imageUrl: imageUrl,
            quantity: quantity
        )
    }
}

struct Order: Identifiable, Codable {
    let id: String
    let userId: String
    let items: [OrderItem]
    let shippingAddress: Address
    let subtotal: Double
    let shippingCost: Double
    let discount: Double
    let total: Double
    var status: OrderStatus
    let paymentMethod: PaymentMethod
    var paymentStatus: PaymentStatus
    let createdAt: Date
    var updatedAt: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    func toDictionary() -> [String: Any] {
        let itemsData = items.map { $0.toDictionary() }
        
        return [
            "id": id,
            "userId": userId,
            "items": itemsData,
            "shippingAddress": shippingAddress.toDictionary(),
            "subtotal": subtotal,
            "shippingCost": shippingCost,
            "discount": discount,
            "total": total,
            "status": status.rawValue,
            "paymentMethod": paymentMethod.rawValue,
            "paymentStatus": paymentStatus.rawValue,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> Order? {
        guard
            let id = dict["id"] as? String,
            let userId = dict["userId"] as? String,
            let itemsData = dict["items"] as? [[String: Any]],
            let shippingAddressData = dict["shippingAddress"] as? [String: Any],
            let subtotal = dict["subtotal"] as? Double,
            let shippingCost = dict["shippingCost"] as? Double,
            let discount = dict["discount"] as? Double,
            let total = dict["total"] as? Double,
            let statusRaw = dict["status"] as? String,
            let paymentMethodRaw = dict["paymentMethod"] as? String,
            let paymentStatusRaw = dict["paymentStatus"] as? String,
            let status = OrderStatus(rawValue: statusRaw),
            let paymentMethod = PaymentMethod(rawValue: paymentMethodRaw),
            let paymentStatus = PaymentStatus(rawValue: paymentStatusRaw)
        else { return nil }
        
        guard let shippingAddress = Address.fromDictionary(shippingAddressData) else { return nil }
        
        let items = itemsData.compactMap { OrderItem.fromDictionary($0) }
        
        // Handle timestamps for dates
        var createdAt = Date()
        var updatedAt = Date()
        
        if let createdTimestamp = dict["createdAt"] as? Timestamp {
            createdAt = createdTimestamp.dateValue()
        }
        
        if let updatedTimestamp = dict["updatedAt"] as? Timestamp {
            updatedAt = updatedTimestamp.dateValue()
        }
        
        return Order(
            id: id,
            userId: userId,
            items: items,
            shippingAddress: shippingAddress,
            subtotal: subtotal,
            shippingCost: shippingCost,
            discount: discount,
            total: total,
            status: status,
            paymentMethod: paymentMethod,
            paymentStatus: paymentStatus,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
