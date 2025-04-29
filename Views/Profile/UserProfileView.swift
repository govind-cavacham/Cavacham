//
//  UserProfileView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

// MARK: - Profile Menu Item Model
struct ProfileMenuItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let action: () -> Void
}

// MARK: - Recent Order Model
struct RecentOrder: Identifiable {
    let id = UUID()
    let orderNumber: String
    let date: String
    let amount: Double
    let status: String
    let statusColor: Color
}

struct UserProfileView: View {
    // MARK: - Environment & State Objects
    @StateObject private var viewModel = UserProfileViewModel()
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    // MARK: - View States
    @State private var showSignOutAlert = false
    @State private var selectedNavigation: ProfileNavigation?
    
    // MARK: - Navigation Enum
    enum ProfileNavigation: Hashable {
        case editProfile
        case addressBook
        case settings
        case orders
        case wishlist
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                if authViewModel.isGuest {
                    GuestProfileView()
                        .environmentObject(authViewModel)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Profile Header
                            ProfileHeaderSection(
                                userName: viewModel.userName,
                                email: authViewModel.email,
                                initials: viewModel.userInitials,
                                onEditProfile: { selectedNavigation = .editProfile }
                            )
                            
                            // Quick Actions
                            QuickActionSection(
                                onOrders: { selectedNavigation = .orders },
                                onWishlist: { selectedNavigation = .wishlist },
                                onAddresses: { selectedNavigation = .addressBook }
                            )
                            
                            // Recent Orders
                            RecentOrdersSection(onViewAll: { selectedNavigation = .orders })
                            
                            // Menu Sections
                            MenuListSection(
                                onEditProfile: { selectedNavigation = .editProfile },
                                onAddressBook: { selectedNavigation = .addressBook },
                                onSettings: { selectedNavigation = .settings },
                                onOrders: { selectedNavigation = .orders },
                                onWishlist: { selectedNavigation = .wishlist }
                            )
                            
                            // Sign Out Button
                            Button(action: { showSignOutAlert = true }) {
                                Text("Sign Out")
                                    .titleSmallStyle()
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.appSurface)
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.large)
                }
            }
            .navigationDestination(for: ProfileNavigation.self) { navigation in
                switch navigation {
                case .editProfile:
                    EditProfileView(userId: authViewModel.userId, viewModel: viewModel)
                        .environmentObject(authViewModel)
                case .addressBook:
                    AddressBookView()
                        .environmentObject(authViewModel)
                case .settings:
                    SettingsView()
                        .environmentObject(authViewModel)
                case .orders:
                    OrdersView()
                        .environmentObject(authViewModel)
                case .wishlist:
                    WishlistView()
                        .environmentObject(authViewModel)
                }
            }
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

// MARK: - Guest Profile View
struct GuestProfileView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.appSecondary)
            
            Text("Guest Mode")
                .titleLargeStyle()
                .foregroundColor(.appTextPrimary)
            
            Text("Sign in to access your profile, orders, and more")
                .bodyLargeStyle()
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            PrimaryButton(
                title: "Sign In",
                icon: "arrow.right"
            ) {
                authViewModel.isGuest = false
                authViewModel.isAuthenticated = false
            }
            .padding(.horizontal)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Profile Header Section
struct ProfileHeaderSection: View {
    let userName: String
    let email: String
    let initials: String
    let onEditProfile: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile Image
            ZStack {
                Circle()
                    .fill(Color.appSecondary.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Text(initials)
                    .titleLargeStyle()
                    .foregroundColor(.appSecondary)
            }
            
            // User Info
            VStack(spacing: 4) {
                Text(userName)
                    .titleMediumStyle()
                    .foregroundColor(.appTextPrimary)
                
                Text(email)
                    .bodyMediumStyle()
                    .foregroundColor(.appTextSecondary)
            }
            
            // Edit Button
            Button(action: onEditProfile) {
                Text("Edit Profile")
                    .labelMediumStyle()
                    .foregroundColor(.appPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.appPrimary.opacity(0.1))
                    .cornerRadius(20)
            }
        }
        .padding(24)
        .background(Color.appSurface)
        .cornerRadius(16)
    }
}

// MARK: - Quick Action Section
struct QuickActionSection: View {
    let onOrders: () -> Void
    let onWishlist: () -> Void
    let onAddresses: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            quickActionButton(title: "Orders", icon: "box", action: onOrders)
            quickActionButton(title: "Wishlist", icon: "heart", action: onWishlist)
            quickActionButton(title: "Addresses", icon: "location", action: onAddresses)
        }
    }
    
    private func quickActionButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Circle()
                    .fill(Color.appPrimary.opacity(0.1))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(.appPrimary)
                    )
                
                Text(title)
                    .labelMediumStyle()
                    .foregroundColor(.appTextPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.appSurface)
            .cornerRadius(12)
        }
    }
}

// MARK: - Recent Orders Section
struct RecentOrdersSection: View {
    let onViewAll: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Orders")
                    .titleMediumStyle()
                
                Spacer()
                
                Button(action: onViewAll) {
                    Text("View All")
                        .labelMediumStyle()
                        .foregroundColor(.appPrimary)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<3) { index in
                        recentOrderCard
                    }
                }
            }
        }
    }
    
    private var recentOrderCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                
                Text("Delivered")
                    .labelSmallStyle()
                    .foregroundColor(.appTextSecondary)
            }
            
            Text("Order #12345")
                .titleSmallStyle()
            
            Text("Apr 27, 2025")
                .labelMediumStyle()
                .foregroundColor(.appTextSecondary)
            
            Text("$149.99")
                .titleSmallStyle()
                .foregroundColor(.appPrimary)
        }
        .padding()
        .frame(width: 160)
        .background(Color.appSurface)
        .cornerRadius(12)
    }
}

// MARK: - Menu List Section
struct MenuListSection: View {
    let onEditProfile: () -> Void
    let onAddressBook: () -> Void
    let onSettings: () -> Void
    let onOrders: () -> Void
    let onWishlist: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Account Section
            menuSection(title: "Account") {
                menuItem(title: "Personal Information", icon: "person", action: onEditProfile)
                menuItem(title: "Saved Addresses", icon: "location", action: onAddressBook)
                menuItem(title: "Settings", icon: "gear", action: onSettings)
            }
            
            // Orders Section
            menuSection(title: "Orders") {
                menuItem(title: "Order History", icon: "clock", action: onOrders)
                menuItem(title: "Wishlist", icon: "heart", action: onWishlist)
            }
            
            // Support Section
            menuSection(title: "Support") {
                menuItem(title: "Help Center", icon: "questionmark.circle") {
                    // Help center action
                }
                menuItem(title: "Contact Us", icon: "message") {
                    // Contact action
                }
            }
        }
    }
    
    private func menuSection<Content: View>(title: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .titleSmallStyle()
                .foregroundColor(.appTextPrimary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content()
            }
            .background(Color.appSurface)
            .cornerRadius(12)
        }
    }
    
    private func menuItem(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.appTextSecondary)
                    .frame(width: 24)
                
                Text(title)
                    .bodyMediumStyle()
                    .foregroundColor(.appTextPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.appTextTertiary)
            }
            .padding(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview Provider
struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
            .environmentObject(AuthViewModel())
    }
} 
