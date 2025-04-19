//
//  CartView.swift
//  Cavacham
//
//  Created by Grok on 14/04/25.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cartVM: CartViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("NeumorphicBackground")
                    .ignoresSafeArea()
                
                if cartVM.cartItems.isEmpty {
                    VStack {
                        Image(systemName: "cart")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(Color("NeumorphicAccent"))
                        Text("Your cart is empty")
                            .font(.system(.title2, design: .rounded, weight: .medium))
                            .foregroundColor(Color("NeumorphicText"))
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(cartVM.cartItems) { item in
                                CartItemView(item: item)
                            }
                            
                            HStack {
                                Text("Total:")
                                    .font(.system(.title2, design: .rounded, weight: .bold))
                                    .foregroundColor(Color("NeumorphicText"))
                                Spacer()
                                Text("₹\(Int(cartVM.totalPrice))")
                                    .font(.system(.title2, design: .rounded, weight: .bold))
                                    .foregroundColor(Color("NeumorphicAccent"))
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("NeumorphicBackground"))
                                    .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                            )
                            .padding(.horizontal)
                            
                            Button(action: {
                                // Implement checkout
                            }) {
                                Text("Proceed to Checkout")
                                    .font(.system(.headline, design: .rounded, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color("NeumorphicBackground"))
                                            .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                            .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                                    )
                                    .foregroundColor(Color("NeumorphicAccent"))
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 80)
                    }
                }
            }
            .navigationTitle("Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Cart")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundColor(Color("NeumorphicText"))
                }
            }
        }
    }
}

struct CartItemView: View {
    let item: CartItem
    @EnvironmentObject private var cartVM: CartViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            if let firstImage = item.crystal.imageURLs?.first, let url = URL(string: firstImage) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } placeholder: {
                    Image(systemName: "sparkles")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color("NeumorphicAccent"))
                        .background(Color("NeumorphicBackground"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                Image(systemName: "sparkles")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color("NeumorphicAccent"))
                    .background(Color("NeumorphicBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.crystal.name)
                    .font(.system(.headline, design: .rounded, weight: .medium))
                    .foregroundColor(Color("NeumorphicText"))
                Text("₹\(Int(item.crystal.price ?? 0))")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(Color("NeumorphicAccent"))
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: {
                    if item.quantity > 0 {
                        cartVM.updateQuantity(itemId: item.id, quantity: item.quantity - 1)
                    }
                }) {
                    Image(systemName: "minus.circle")
                        .foregroundColor(Color("NeumorphicAccent"))
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color("NeumorphicBackground"))
                                .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                        )
                }
                
                Text("\(item.quantity)")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(Color("NeumorphicText"))
                
                Button(action: {
                    cartVM.updateQuantity(itemId: item.id, quantity: item.quantity + 1)
                }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(Color("NeumorphicAccent"))
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color("NeumorphicBackground"))
                                .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("NeumorphicBackground"))
                .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
        )
        .padding(.horizontal)
    }
}

#Preview {
    CartView()
        .environmentObject(CartViewModel())
}
