//
//  CrystalDetailView.swift
//  Cavacham
//
//  Created by Govind Pathak on 13/04/25.
//

import SwiftUI

struct CrystalDetailView: View {
    let crystal: Crystal
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cartVM: CartViewModel
    @State private var selectedImageIndex = 0
    @State private var addedToCart = false
    
    private func fallbackImageView() -> some View {
        Image(systemName: "sparkles")
            .resizable()
            .scaledToFit()
            .frame(height: UIScreen.main.bounds.height * 0.35)
            .foregroundColor(Color("NeumorphicAccent"))
            .background(Color("NeumorphicBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func InfoSection(title: String, content: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color("NeumorphicText").opacity(0.9))
                .padding(.bottom, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(content, id: \.self) { line in
                    Text("• \(line)")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(Color("NeumorphicText"))
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
    }
    
    // Tags for crystals (example properties)
    private var crystalTags: [String] {
        switch crystal.id.lowercased() {
        case "blacktourmaline":
            return ["Protection", "Grounding"]
        case "7chakras":
            return ["Balance", "Harmony"]
        case "amethyst":
            return ["Intuition", "Calmness"]
        default:
            return ["Healing", "Energy"]
        }
    }
    
    var body: some View {
        ZStack {
            Color("NeumorphicBackground")
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    // Hero Image
                    ZStack {
                        if let imageURL = crystal.imageURLs?.first(where: { !$0.isEmpty }), let url = URL(string: imageURL) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: UIScreen.main.bounds.height * 0.35)
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                            } placeholder: {
                                fallbackImageView()
                            }
                        } else {
                            fallbackImageView()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color("NeumorphicBackground"))
                            .shadow(color: .white.opacity(0.7), radius: 6, x: -6, y: -6)
                            .shadow(color: .black.opacity(0.2), radius: 6, x: 6, y: 6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color("NeumorphicBackground").opacity(0.8), Color("NeumorphicBackground").opacity(0.9)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                    )
                    
                    // Title and Price
                    VStack(alignment: .center, spacing: 8) {
                        Text(crystal.name)
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundColor(Color("NeumorphicText"))
                            .multilineTextAlignment(.center)
                        
                        if let price = crystal.price {
                            Text("₹\(Int(price))")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color("NeumorphicAccent"))
                        } else {
                            Text("Price Unavailable")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(Color("NeumorphicAccent"))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Tags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(crystalTags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                                    .foregroundColor(Color("NeumorphicText"))
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(
                                        Capsule()
                                            .fill(Color("NeumorphicBackground"))
                                            .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                            .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                                    )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    
                    // Detail Sections
                    VStack(spacing: 24) {
                        InfoSection(title: "Description", content: crystal.description)
                        InfoSection(title: "How to Use", content: crystal.howToUse)
                        InfoSection(title: "Impact", content: crystal.impact)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 80)
                }
            }
            
            // Back Button
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.title)
                                .foregroundColor(Color("NeumorphicText"))
                            Text("Back")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundColor(Color("NeumorphicText"))
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("NeumorphicBackground"))
                                .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                        )
                    }
                    Spacer()
                }
                .padding()
                Spacer()
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        cartVM.addToCart(crystal: crystal)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation(.spring()) {
                            addedToCart = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                addedToCart = false
                            }
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color("NeumorphicBackground"))
                                .frame(width: UIScreen.main.bounds.width * 0.28, height: 45)
                                .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                .shadow(color: addedToCart ? .black.opacity(0.3) : .black.opacity(0.2), radius: 4, x: 4, y: 4)
                            
                            HStack(spacing: 8) {
                                Image(systemName: addedToCart ? "checkmark" : "cart.fill")
                                    .foregroundColor(Color("NeumorphicAccent"))
                                    .font(.subheadline)
                                Text("Add to Cart")
                                    .font(.system(.caption, design: .rounded, weight: .bold))
                                    .foregroundColor(Color("NeumorphicAccent"))
                            }
                        }
                    }
                    .scaleEffect(addedToCart ? 1.1 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: addedToCart)
                    .padding(.trailing, 24)
                    .padding(.bottom, 16)
                    .accessibilityLabel("Add \(crystal.name) to cart")
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    CrystalDetailView(crystal: Crystal.allCrystals.first!)
        .environmentObject(CartViewModel())
}
