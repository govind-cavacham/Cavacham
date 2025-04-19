//
//  HomeView.swift
//  Cavacham
//
//  Created by Govind Pathak on 13/04/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var launchVM = NewLaunchViewModel()
    @StateObject private var crystalVM = CrystalViewModel()
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    @State private var showCart = false

    let filters = ["All", "Featured", "Crystals", "New Arrivals"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color("NeumorphicBackground")
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    HomeContentView(
                        launchVM: launchVM,
                        crystalVM: crystalVM,
                        searchText: $searchText,
                        selectedFilter: $selectedFilter,
                        filters: filters,
                        showCart: $showCart
                    )
                }
                .refreshable {
                    await crystalVM.fetchCrystalsAsync()
                    await launchVM.fetchNewLaunchesAsync()
                }
                
                if let error = launchVM.errorMessage ?? crystalVM.errorMessage {
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
            .navigationTitle("Cavacham")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Cavacham")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundColor(Color("NeumorphicText"))
                }
            }
            .onAppear {
                crystalVM.fetchCrystals()
                launchVM.fetchNewLaunches()
            }
        }
    }
}

struct HomeContentView: View {
    @ObservedObject var launchVM: NewLaunchViewModel
    @ObservedObject var crystalVM: CrystalViewModel
    @Binding var searchText: String
    @Binding var selectedFilter: String
    let filters: [String]
    @Binding var showCart: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            buildHeader()
            buildSearchBar()
            buildNewLaunchCarousel()
            buildFilters()
            buildProductGrid()
        }
        .padding(.bottom, 80)
    }

    private var filteredItems: [ProductItem] {
        let launchItems: [ProductItem] = launchVM.launches.map {
            ProductItem(
                id: $0.id ?? UUID().uuidString,
                title: $0.title,
                price: $0.price ?? 0.0,
                imageURL: $0.image ?? "",
                type: .launch($0)
            )
        }
        
        let crystalItems: [ProductItem] = crystalVM.crystals.map {
            ProductItem(
                id: $0.id,
                title: $0.name,
                price: $0.price ?? 0.0,
                imageURL: $0.imageURLs?.first ?? "",
                type: .crystal($0)
            )
        }
        
        var combinedItems = launchItems + crystalItems
        
        if !searchText.isEmpty {
            combinedItems = combinedItems.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        switch selectedFilter {
        case "Crystals":
            return combinedItems.filter {
                if case .crystal = $0.type { return true }
                return false
            }
        case "New Arrivals":
            return combinedItems.filter {
                if case .launch = $0.type { return true }
                return false
            }
        case "Featured":
            return Array(combinedItems.shuffled().prefix(4))
        default:
            return combinedItems
        }
    }

    @ViewBuilder
    private func buildHeader() -> some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(Color("NeumorphicText"))
                .padding(10)
                .background(
                    Circle()
                        .fill(Color("NeumorphicBackground"))
                        .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                )
            Spacer()
            Image(systemName: "cart")
                .font(.title2)
                .foregroundColor(Color("NeumorphicText"))
                .padding(10)
                .background(
                    Circle()
                        .fill(Color("NeumorphicBackground"))
                        .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                )
                .onTapGesture {
                    showCart = true
                }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    @ViewBuilder
    private func buildSearchBar() -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color("NeumorphicText"))
            TextField("Search Crystals & More", text: $searchText)
                .foregroundColor(Color("NeumorphicText"))
                .autocapitalization(.none)
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

    @ViewBuilder
    private func buildNewLaunchCarousel() -> some View {
        if launchVM.launches.isEmpty {
            EmptyView()
        } else {
            TabView {
                ForEach(launchVM.launches) { launch in
                    NewLaunchBanner(launch: launch)
                        .padding(.horizontal)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 200)
            .padding(.vertical)
        }
    }

    @ViewBuilder
    private func buildFilters() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(filters, id: \.self) { filter in
                    FilterChip(title: filter, isSelected: selectedFilter == filter) {
                        withAnimation { selectedFilter = filter }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func buildProductGrid() -> some View {
        if crystalVM.crystals.isEmpty && launchVM.launches.isEmpty && crystalVM.errorMessage == nil && launchVM.errorMessage == nil {
            ProgressView()
                .tint(Color("NeumorphicAccent"))
                .padding()
        } else {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(filteredItems) { item in
                    ProductCard(item: item)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct NewLaunchBanner: View {
    let launch: NewLaunch
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("NeumorphicBackground"))
                .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(launch.title)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundColor(Color("NeumorphicText"))
                    Text(launch.subtitle ?? "New Arrival")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(Color("NeumorphicText"))
                    if let price = launch.price {
                        Text("₹\(Int(price))")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundColor(Color("NeumorphicAccent"))
                    }
                }
                .padding(.leading, 20)
                .padding(.vertical)
                
                Spacer()
                
                if let imageURL = launch.image, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                    } placeholder: {
                        Image(systemName: "sparkles")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color("NeumorphicAccent"))
                    }
                    .padding(.trailing, 20)
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        ZStack {
            if isSelected {
                // Pressed effect
                Capsule()
                    .fill(Color("NeumorphicBackground"))
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                    .overlay(
                        Capsule()
                            .stroke(Color("NeumorphicShadow"), lineWidth: 1)
                    )
            } else {
                // Raised effect
                Capsule()
                    .fill(Color("NeumorphicBackground"))
                    .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
            }
            
            Text(title)
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundColor(isSelected ? Color("NeumorphicAccent") : Color("NeumorphicText"))
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
        }
        .onTapGesture { action() }
    }
}

struct ProductItem: Identifiable {
    let id: String
    let title: String
    let price: Double
    let imageURL: String
    let type: ProductType
    
    enum ProductType {
        case crystal(Crystal)
        case launch(NewLaunch)
    }
}

struct ProductCard: View {
    let item: ProductItem
    @EnvironmentObject var cartVM: CartViewModel
    @State private var isHovered = false
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            VStack(spacing: 12) {
                if !item.imageURL.isEmpty, let url = URL(string: item.imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } placeholder: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color("NeumorphicBackground"))
                                .frame(height: 140)
                            Image(systemName: "sparkles")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 60)
                                .foregroundColor(Color("NeumorphicAccent"))
                        }
                    }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("NeumorphicBackground"))
                            .frame(height: 140)
                        Image(systemName: "sparkles")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                            .foregroundColor(Color("NeumorphicAccent"))
                    }
                }
                
                Text(item.title)
                    .font(.system(.headline, design: .rounded, weight: .medium))
                    .foregroundColor(Color("NeumorphicText"))
                    .lineLimit(1)
                
                Text("₹\(Int(item.price))")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(Color("NeumorphicAccent"))
                
                Button(action: {
                    switch item.type {
                    case .crystal(let crystal):
                        cartVM.addToCart(crystal: crystal)
                    case .launch(let launch):
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
                    }
                }) {
                    Text("Add to Cart")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color("NeumorphicBackground"))
                                    .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                            }
                        )
                        .foregroundColor(Color("NeumorphicAccent"))
                }
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
    
    @ViewBuilder
    private var destinationView: some View {
        switch item.type {
        case .crystal(let crystal):
            CrystalDetailView(crystal: crystal)
        case .launch(let launch):
            NewLaunchDetailView(launch: launch)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(CartViewModel())
}
