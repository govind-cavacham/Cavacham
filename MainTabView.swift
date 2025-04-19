//
//  MainTabView.swift
//  Cavacham
//
//  Created by Govind Pathak on 13/04/25.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case home = "house.fill"
    case crystals = "sparkles"
    case cart = "cart.fill"
    case profile = "person.crop.circle.fill"
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @AppStorage("userEmail") var userEmail: String?
    @StateObject private var cartVM = CartViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if selectedTab == .home {
                    HomeView()
                } else if selectedTab == .crystals {
                    CrystalsView()
                } else if selectedTab == .cart {
                    CartView()
                } else if selectedTab == .profile {
                    if userEmail == nil {
                        WelcomeAuthView()
                    } else {
                        ProfileView()
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environmentObject(cartVM)

            HStack {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation { selectedTab = tab }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: tab.rawValue)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(selectedTab == tab ? Color("NeumorphicAccent") : Color.gray.opacity(0.7))
                                .scaleEffect(selectedTab == tab ? 1.2 : 1.0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: selectedTab)
                            Text(tabText(for: tab))
                                .font(.system(.caption, design: .rounded).bold())
                                .foregroundColor(selectedTab == tab ? Color("NeumorphicAccent") : Color.gray.opacity(0.6))
                        }
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            Circle()
                                .fill(Color("NeumorphicBackground"))
                                .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                .shadow(color: .black.opacity(0.2), radius: 6, x: 6, y: 6)
                                .frame(width: 60, height: 60)
                                .opacity(selectedTab == tab ? 1.0 : 0.0)
                        )
                        .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                    }
                    .accessibilityLabel(tabText(for: tab))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            .background(
                ZStack {
                    BlurView(style: .systemUltraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("NeumorphicBackground").opacity(0.6))
                        .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                        .shadow(color: .black.opacity(0.2), radius: 6, x: 6, y: 6)
                }
            )
        }
        .background(Color("NeumorphicBackground").ignoresSafeArea())
    }

    private func tabText(for tab: Tab) -> String {
        switch tab {
        case .home: return "Home"
        case .crystals: return "Crystals"
        case .cart: return "Cart"
        case .profile: return "Profile"
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(CartViewModel())
}
