//
//  OrderViewModel.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class OrderViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var currentOrder: Order?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var orderSuccess = false
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    // MARK: - Order Creation
    
    /// Creates a new order in Firestore
    func createOrder(
        items: [CartItem],
        subtotal: Double,
        shipping: Double,
        discount: Double,
        total: Double,
        shippingAddress: Address,
        paymentMethod: PaymentMethod
    ) async throws -> Order {
        guard let user = auth.currentUser else {
            throw AppError.notAuthenticated
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // Convert cart items to order items format
        let orderItems = items.map { cartItem in
            OrderItem(
                productId: cartItem.productId,
                name: cartItem.productName,
                price: cartItem.price,
                discountedPrice: cartItem.price,
                imageUrl: cartItem.imageUrl,
                quantity: cartItem.quantity
            )
        }
        
        // Create order model
        let newOrder = Order(
            id: UUID().uuidString,
            userId: user.uid,
            items: orderItems,
            shippingAddress: shippingAddress,
            subtotal: subtotal,
            shippingCost: shipping,
            discount: discount,
            total: total,
            status: .pending,
            paymentMethod: paymentMethod,
            paymentStatus: paymentMethod == .cashOnDelivery ? .pending : .completed,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // Save to Firestore
        do {
            let orderData = newOrder.toDictionary()
            try await db.collection("orders").document(newOrder.id).setData(orderData)
            
            // Add order to published property
            await MainActor.run {
                self.orders.insert(newOrder, at: 0)
                self.currentOrder = newOrder
                self.orderSuccess = true
            }
            
            return newOrder
        } catch {
            self.error = error
            throw error
        }
    }
    
    // MARK: - Order Retrieval
    
    /// Loads all orders for the current user
    func loadOrders() async {
        guard let user = auth.currentUser else {
            self.error = AppError.notAuthenticated
            return
        }
        
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            let snapshot = try await db.collection("orders")
                .whereField("userId", isEqualTo: user.uid)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let ordersList = snapshot.documents.compactMap { document -> Order? in
                let data = document.data()
                return Order.fromDictionary(data)
            }
            
            await MainActor.run {
                self.orders = ordersList
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    /// Loads a specific order by ID
    func loadOrder(id: String) async throws -> Order {
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            let document = try await db.collection("orders").document(id).getDocument()
            
            guard let data = document.data(), document.exists else {
                throw AppError.notFound
            }
            
            guard let order = Order.fromDictionary(data) else {
                throw AppError.invalidData
            }
            
            await MainActor.run {
                self.currentOrder = order
                self.isLoading = false
            }
            
            return order
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
            
            throw error
        }
    }
    
    // MARK: - Order Cancellation
    
    /// Cancels an order with the given ID
    func cancelOrder(id: String) async throws {
        guard let user = auth.currentUser else {
            throw AppError.notAuthenticated
        }
        
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            // Get the order first to verify it belongs to the user
            let document = try await db.collection("orders").document(id).getDocument()
            
            guard let data = document.data(), document.exists else {
                throw AppError.notFound
            }
            
            guard let userId = data["userId"] as? String, userId == user.uid else {
                throw AppError.notAuthorized
            }
            
            // Check if the order can be cancelled
            if let statusString = data["status"] as? String,
               let status = OrderStatus(rawValue: statusString),
               status != .pending && status != .processing {
                throw AppError.invalidOperation(message: "Cannot cancel order in \(status.rawValue) status")
            }
            
            // Update the order status
            try await db.collection("orders").document(id).updateData([
                "status": OrderStatus.cancelled.rawValue,
                "updatedAt": Timestamp(date: Date())
            ])
            
            // Update the local order if it's in the array
            await MainActor.run {
                if let index = self.orders.firstIndex(where: { $0.id == id }) {
                    self.orders[index].status = .cancelled
                    self.orders[index].updatedAt = Date()
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
            
            throw error
        }
    }
    
    // Update order status (for Razorpay or other payment confirmations)
    func updateOrderPayment(orderId: String, paymentId: String, success: Bool) async -> Bool {
        isLoading = true
        error = nil
        
        do {
            if success {
                // Payment successful, update order
                try await db.collection("orders").document(orderId).updateData([
                    "paymentId": paymentId,
                    "status": OrderStatus.processing.rawValue,
                    "updatedAt": FieldValue.serverTimestamp()
                ])
                
                orderSuccess = true
            } else {
                // Payment failed, update order status
                try await db.collection("orders").document(orderId).updateData([
                    "status": OrderStatus.cancelled.rawValue,
                    "updatedAt": FieldValue.serverTimestamp()
                ])
                
                self.error = AppError.paymentError(message: "Payment failed")
            }
            
            // Reload the order
            try await loadOrder(id: orderId)
            
            isLoading = false
            return success
        } catch {
            self.error = error
            isLoading = false
            print("⚠️ Error updating order payment: \(error.localizedDescription)")
            return false
        }
    }
}
