//
//  MainTabView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var cartViewModel = CartViewModel()
    @StateObject private var productViewModel = ProductViewModel()
    @StateObject private var categoryViewModel = CategoryViewModel()
    
    var body: some View {
        TabView {
            HomeView()
                .environmentObject(productViewModel)
                .environmentObject(categoryViewModel)
                .environmentObject(cartViewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            SearchView()
                .environmentObject(productViewModel)
                .environmentObject(cartViewModel)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            CartView()
                .environmentObject(cartViewModel)
                .tabItem {
                    Label("Cart", systemImage: "cart.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(CartViewModel())
            .environmentObject(ProductViewModel())
            .environmentObject(CategoryViewModel())
    }
}
