//
//  ContentView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var isLoading = true
    @State private var showAuth = false
    
    var body: some View {
        ZStack {
            if isLoading {
                splashScreen
            } else if authViewModel.isAuthenticated || authViewModel.isGuest {
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                welcomeView
            }
        }
        .onAppear {
            // Simulate loading time (2 seconds)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    isLoading = false
                }
            }
        }
        .sheet(isPresented: $showAuth) {
            AuthenticationView()
                .environmentObject(authViewModel)
        }
    }
    
    // Splash Screen
    private var splashScreen: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.appPrimary, .appSecondary]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // App logo/icon
                Image(systemName: "sparkles")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .frame(width: 120, height: 120)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(30)
                
                // App name
                Text("Cavacham")
                    .displayMediumStyle()
                    .foregroundColor(.white)
                
                // App tagline
                Text("Explore the magic of crystals")
                    .titleSmallStyle()
                    .foregroundColor(.white.opacity(0.8))
            }
            .offset(y: -20)
        }
    }
    
    // Welcome View
    private var welcomeView: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.appPrimary, .appSecondary]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // App logo and name
                VStack(spacing: 24) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .frame(width: 120, height: 120)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(30)
                    
                    Text("Cavacham")
                        .displayMediumStyle()
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Welcome message
                VStack(spacing: 16) {
                    Text("Welcome to Cavacham")
                        .titleLargeStyle()
                        .foregroundColor(.white)
                    
                    Text("Discover and shop the finest crystals for your spiritual journey")
                        .bodyLargeStyle()
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    PrimaryButton(
                        title: "Get Started",
                        icon: "arrow.right",
                        action: { showAuth = true }
                    )
                    
                    Button(action: { authViewModel.continueAsGuest() }) {
                        Text("Continue as Guest")
                            .titleSmallStyle()
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 48)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
