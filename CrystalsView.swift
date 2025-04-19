//
//  CrystalsView.swift
//  Cavacham
//
//  Created by Govind Pathak on 12/04/25.
//

import SwiftUI

struct CrystalsView: View {
    @StateObject private var crystalVM = CrystalViewModel()
    @State private var animateIn = false
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("NeumorphicBackground")
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Crystals")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundColor(Color("NeumorphicText"))
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    if crystalVM.crystals.isEmpty, crystalVM.errorMessage == nil {
                        ProgressView()
                            .tint(Color("NeumorphicAccent"))
                            .padding()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(crystalVM.crystals) { crystal in
                                    CrystalCard(crystal: crystal)
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            await crystalVM.fetchCrystalsAsync()
                        }
                    }
                }
                .opacity(animateIn ? 1 : 0)
                .animation(.easeOut(duration: 0.5), value: animateIn)
                
                if let error = crystalVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("NeumorphicBackground"))
                                .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                        )
                        .padding(.top)
                }
            }
            .navigationTitle("Crystals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Crystals")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundColor(Color("NeumorphicText"))
                }
            }
            .onAppear {
                animateIn = true
                crystalVM.fetchCrystals()
            }
        }
    }
}

struct CrystalCard: View {
    let crystal: Crystal
    @State private var isHovered = false
    
    var body: some View {
        NavigationLink(destination: CrystalDetailView(crystal: crystal)) {
            VStack(spacing: 12) {
                if let firstImage = crystal.imageURLs?.first, let url = URL(string: firstImage) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } placeholder: {
                        Image(systemName: "sparkles")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .foregroundColor(Color("NeumorphicAccent"))
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color("NeumorphicBackground"))
                            )
                    }
                } else {
                    // Fallback to local placeholder image based on crystal ID
                    Image(localImageName(for: crystal.id))
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Text(crystal.name)
                    .font(.system(.headline, design: .rounded, weight: .medium))
                    .foregroundColor(Color("NeumorphicText"))
                    .lineLimit(1)
                
                Text(crystal.price != nil ? "₹\(Int(crystal.price!))" : "Price unavailable")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(Color("NeumorphicAccent"))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("NeumorphicBackground"))
                    .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
            )
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.spring(), value: isHovered)
            .onHover { isHovered = $0 }
        }
    }
    
    // Map crystal ID to local placeholder image name
    private func localImageName(for crystalId: String) -> String {
        switch crystalId.lowercased() {
        case "selenite":
            return "selenite"
        case "blacktourmaline":
            return "blacktourmaline"
        case "greenaventurine":
            return "greenaventurine"
        case "citrine":
            return "citrine"
        case "7chakras":
            return "7chakras"
        case "amethyst":
            return "amethyst"
        case "carnelian":
            return "carnelian"
        case "lapislazuli":
            return "lapislazuli"
        case "moonstone":
            return "moonstone"
        case "pyrite":
            return "pyrite"
        case "rosequartz":
            return "rosequartz"
        case "sphatic":
            return "sphatic"
        case "sunstone":
            return "sunstone"
        case "tigereye":
            return "tigereye"
        case "turquoise":
            return "turquoise"
        default:
            return "sparkles" // Fallback to system image if no local image is found
        }
    }
}

#Preview {
    CrystalsView()
}
