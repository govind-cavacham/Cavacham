//
//  NewLaunchDetailView.swift
//  Cavacham
//
//  Created by Govind Pathak on 13/04/25.
//

import SwiftUI

struct NewLaunchDetailView: View {
    let launch: NewLaunch
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cartVM: CartViewModel
    @State private var addedToCart = false
    
    // Tags for new launches (example tags)
    private var launchTags: [String] {
        return ["New Arrival", "Limited Edition"]
    }
    
    var body: some View {
        ZStack {
            Color("NeumorphicBackground")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Hero Image
                    ZStack {
                        if let imageURL = launch.image, let url = URL(string: imageURL) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color("NeumorphicBackground"))
                                        .frame(height: 300)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 300)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                case .failure(_):
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 300)
                                        .foregroundColor(Color("NeumorphicAccent"))
                                        .background(Color("NeumorphicBackground"))
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: "sparkles")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                                .foregroundColor(Color("NeumorphicAccent"))
                                .background(Color("NeumorphicBackground"))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("NeumorphicBackground"))
                            .shadow(color: .white.opacity(0.7), radius: 6, x: -6, y: -6)
                            .shadow(color: .black.opacity(0.2), radius: 6, x: 6, y: 6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color("NeumorphicBackground").opacity(0.8), Color("NeumorphicBackground").opacity(0.9)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Title, Subtitle, and Price
                    VStack(alignment: .center, spacing: 8) {
                        Text(launch.title)
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundColor(Color("NeumorphicText"))
                            .multilineTextAlignment(.center)
                        
                        if let subtitle = launch.subtitle {
                            Text(subtitle)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(Color("NeumorphicText"))
                        }
                        
                        if let price = launch.price {
                            Text("₹\(Int(price))")
                                .font(.system(.title2, design: .rounded, weight: .bold))
                                .foregroundColor(Color("NeumorphicAccent"))
                        } else {
                            Text("Price unavailable")
                                .font(.system(.title2, design: .rounded, weight: .bold))
                                .foregroundColor(Color("NeumorphicAccent"))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Tags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(launchTags, id: \.self) { tag in
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
                        // Description Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Description")
                                .font(.system(.title, design: .rounded, weight: .bold))
                                .foregroundColor(Color("NeumorphicText").opacity(0.9))
                                .padding(.bottom, 4)
                            
                            Text(launch.description.joined(separator: " "))
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(Color("NeumorphicText"))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color("NeumorphicBackground"))
                                .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                        )
                        
                        // How to Use Section
                        if let howToUse = launch.howToUse, !howToUse.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("How to Use")
                                    .font(.system(.title, design: .rounded, weight: .bold))
                                    .foregroundColor(Color("NeumorphicText").opacity(0.9))
                                    .padding(.bottom, 4)
                                
                                Text(howToUse.joined(separator: " "))
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(Color("NeumorphicText"))
                                    .lineSpacing(4)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color("NeumorphicBackground"))
                                    .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                            )
                        }
                        
                        // Impact Section
                        if let impact = launch.impact, !impact.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Impact")
                                    .font(.system(.title, design: .rounded, weight: .bold))
                                    .foregroundColor(Color("NeumorphicText").opacity(0.9))
                                    .padding(.bottom, 4)
                                
                                Text(impact.joined(separator: " "))
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(Color("NeumorphicText"))
                                    .lineSpacing(4)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color("NeumorphicBackground"))
                                    .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                            )
                        }
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
                        cartVM.addToCart(crystal: Crystal(
                            id: launch.id ?? UUID().uuidString,
                            name: launch.title,
                            price: launch.price,
                            description: launch.description,
                            howToUse: launch.howToUse ?? [],
                            impact: launch.impact ?? [],
                            imageURLs: launch.images,
                            timestamp: launch.timestamp
                        ))
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
                                .frame(width: 100, height: 40)
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
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NewLaunchDetailView(launch: NewLaunch(
        id: "1",
        title: "Sample Launch",
        subtitle: "Subtitle",
        description: ["Desc 1", "Desc 2", "Desc 3"],
        howToUse: ["Use"],
        impact: ["Impact"],
        image: "https://example.com/image.jpg",
        images: ["https://example.com/image.jpg"],
        price: 799.0,
        timestamp: Date()
    ))
    .environmentObject(CartViewModel())
}
