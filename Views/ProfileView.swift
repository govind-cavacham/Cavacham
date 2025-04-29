//
//  ProfileView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct ProfileView: View {
    // States for user information
    @StateObject private var authService = AuthService()
    @State private var showLogin = false
    
    // Profile menu options
    private let menuItems = [
        MenuItem(icon: "bag", title: "My Orders", action: .orders),
        MenuItem(icon: "heart", title: "Wishlist", action: .wishlist),
        MenuItem(icon: "mappin.and.ellipse", title: "Addresses", action: .addresses),
        MenuItem(icon: "creditcard", title: "Payment Methods", action: .payments),
        MenuItem(icon: "bell", title: "Notifications", action: .notifications),
        MenuItem(icon: "questionmark.circle", title: "Help & Support", action: .help)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    profileHeader
                    
                    // Menu Items
                    VStack(spacing: 0) {
                        ForEach(menuItems) { item in
                            menuItemRow(item: item)
                            
                            if item != menuItems.last {
                                Divider()
                                    .padding(.leading, 56)
                            }
                        }
                    }
                    .background(Color.appSurface)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Logout Button
                    if authService.isAuthenticated {
                        AppButton(
                            title: "Log Out",
                            icon: "arrow.right.square",
                            action: {
                                try? authService.signOut()
                            }, style: .tertiary
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)
                    } else {
                        AppButton(
                            title: "Sign In",
                            icon: "arrow.right.square",
                            action: {
                                showLogin = true
                            }
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    
                    // App Information
                    Text("Cavacham v1.0.0")
                        .bodySmallStyle()
                        .foregroundColor(.appTextTertiary)
                        .padding(.top, 32)
                }
                .padding(.vertical)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Profile")
            .sheet(isPresented: $showLogin) {
                LoginView()
            }
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 20) {
            // Avatar
            if let user = authService.currentUser, let photoURL = user.photoURL {
                AsyncImage(url: photoURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.appPrimary)
                    @unknown default:
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.appPrimary)
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.appSecondary.opacity(0.3), lineWidth: 2)
                )
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.appPrimary)
                    .frame(width: 100, height: 100)
                    .background(Color.appSurface)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.appSecondary.opacity(0.3), lineWidth: 2)
                    )
            }
            
            // User Info
            VStack(spacing: 4) {
                Text(authService.currentUser?.name ?? "Guest User")
                    .titleLargeStyle()
                    .foregroundColor(.appTextPrimary)
                
                if let user = authService.currentUser {
                    Text(user.email)
                        .bodyMediumStyle()
                        .foregroundColor(.appTextSecondary)
                } else {
                    Text("Sign in to manage your account")
                        .bodyMediumStyle()
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.appSurface)
    }
    
    // MARK: - Menu Item Row
    private func menuItemRow(item: MenuItem) -> some View {
        Button(action: {
            // Handle menu item action
            handleMenuAction(item.action)
        }) {
            HStack(spacing: 16) {
                Image(systemName: item.icon)
                    .font(.system(size: 18))
                    .foregroundColor(.appPrimary)
                    .frame(width: 24, height: 24)
                
                Text(item.title)
                    .bodyLargeStyle()
                    .foregroundColor(.appTextPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.appTextTertiary)
            }
            .padding(16)
        }
    }
    
    // MARK: - Actions
    private func handleMenuAction(_ action: MenuAction) {
        // If not authenticated, show login for restricted actions
        if !authService.isAuthenticated && (action == .orders || action == .wishlist || action == .addresses || action == .payments) {
            showLogin = true
            return
        }
        
        // Handle specific menu actions
        switch action {
        case .orders:
            print("Show orders")
        case .wishlist:
            print("Show wishlist")
        case .addresses:
            print("Show addresses")
        case .payments:
            print("Show payment methods")
        case .notifications:
            print("Show notifications settings")
        case .help:
            print("Show help & support")
        }
    }
}

// MARK: - Supporting Types
struct MenuItem: Identifiable, Equatable {
    let id = UUID()
    let icon: String
    let title: String
    let action: MenuAction
    
    static func == (lhs: MenuItem, rhs: MenuItem) -> Bool {
        lhs.title == rhs.title && lhs.icon == rhs.icon && lhs.action == rhs.action
    }
}

enum MenuAction: Equatable {
    case orders
    case wishlist
    case addresses
    case payments
    case notifications
    case help
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthService())
    }
}
