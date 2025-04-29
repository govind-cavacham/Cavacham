//
//  OrdersView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct OrdersView: View {
    // Environment
    @Environment(\.presentationMode) private var presentationMode
    
    // View model
    @StateObject private var orderViewModel = OrderViewModel()
    @StateObject private var authService = AuthService()
    
    // View state
    @State private var selectedOrder: Order?
    @State private var showOrderDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                if !authService.isAuthenticated {
                    notAuthenticatedView
                } else if orderViewModel.isLoading {
                    loadingView
                } else if orderViewModel.orders.isEmpty {
                    emptyOrdersView
                } else {
                    ordersList
                }
            }
            .navigationTitle("My Orders")
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await orderViewModel.loadOrders()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
            .onAppear {
                Task {
                    await orderViewModel.loadOrders()
                }
            }
            .sheet(isPresented: $showOrderDetail) {
                if let order = selectedOrder {
                    OrderDetailView(order: order)
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var ordersList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(orderViewModel.orders) { order in
                    OrderCard(order: order)
                        .onTapGesture {
                            selectedOrder = order
                            showOrderDetail = true
                        }
                }
            }
            .padding()
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading orders...")
                .bodyMediumStyle()
                .foregroundColor(.appTextSecondary)
                .padding(.top, 16)
        }
    }
    
    private var emptyOrdersView: some View {
        VStack(spacing: 24) {
            Image(systemName: "bag.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.appSecondary)
            
            Text("No Orders Yet")
                .titleLargeStyle()
                .foregroundColor(.appTextPrimary)
            
            Text("You haven't placed any orders yet. Start shopping to see your orders here.")
                .bodyMediumStyle()
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            AppButton(
                title: "Browse Products",
                icon: "cart",
                action: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .padding(.top, 16)
        }
    }
    
    private var notAuthenticatedView: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.appSecondary)
            
            Text("Sign In Required")
                .titleLargeStyle()
                .foregroundColor(.appTextPrimary)
            
            Text("You need to be signed in to view your orders")
                .bodyMediumStyle()
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            AppButton(
                title: "Sign In",
                icon: "person.fill",
                action: {
                    // Show login view
                }
            )
            .padding(.top, 16)
        }
    }
}

// MARK: - Order Card
struct OrderCard: View {
    let order: Order
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with order ID and date
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order #\(order.id.prefix(8))")
                        .titleSmallStyle()
                        .foregroundColor(.appTextPrimary)
                    
                    Text(order.formattedDate)
                        .labelMediumStyle()
                        .foregroundColor(.appTextSecondary)
                }
                
                Spacer()
                
                // Status badge
                StatusBadge(status: order.status)
            }
            
            Divider()
            
            // Order items summary
            HStack {
                // Show first item image with count if there are more
                if let firstItem = order.items.first {
                    ZStack(alignment: .topTrailing) {
                        AsyncImage(url: URL(string: firstItem.imageUrl)) { phase in
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
                        
                        if order.items.count > 1 {
                            Text("+\(order.items.count - 1)")
                                .labelSmallStyle()
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.appSecondary)
                                .cornerRadius(8)
                                .offset(x: 5, y: -5)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(order.items.count) \(order.items.count == 1 ? "item" : "items")")
                        .bodyMediumStyle()
                        .foregroundColor(.appTextPrimary)
                    
                    Text("Total: ₹\(Int(order.total))")
                        .titleSmallStyle()
                        .foregroundColor(.appTextPrimary)
                }
                
                Spacer()
                
                // Payment method badge
                HStack(spacing: 4) {
                    Image(systemName: order.paymentMethod.iconName)
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                    
                    Text(order.paymentMethod.displayName)
                        .labelSmallStyle()
                        .foregroundColor(.appTextSecondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.appSurface)
                .cornerRadius(8)
            }
            
            Divider()
            
            // Action buttons
            HStack {
                Spacer()
                
                // View Details button
                HStack(spacing: 4) {
                    Image(systemName: "doc.text")
                        .font(.caption)
                    
                    Text("View Details")
                        .labelMediumStyle()
                }
                .foregroundColor(.appPrimary)
                
                Spacer()
                
                // Cancel Order button (show only for pending/processing orders)
                if order.status == .pending || order.status == .processing {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle")
                            .font(.caption)
                        
                        Text("Cancel Order")
                            .labelMediumStyle()
                    }
                    .foregroundColor(.appError)
                    
                    Spacer()
                }
                
                // Track Order button (show for shipped orders)
                if order.status == .shipped {
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                            .font(.caption)
                        
                        Text("Track Order")
                            .labelMediumStyle()
                    }
                    .foregroundColor(.appEnergy)
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(Color.appSurface)
        .cornerRadius(16)
    }
}

// MARK: - Status Badge
// Removing duplicate StatusBadge struct since it's now in Components/StatusBadge.swift

struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        OrdersView()
    }
} 
