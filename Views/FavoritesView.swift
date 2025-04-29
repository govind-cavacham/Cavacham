//
//  FavoritesView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var showAuth = false
    
    var body: some View {
        NavigationView {
            Group {
                if authViewModel.isGuest {
                    guestView
                } else if authViewModel.isAuthenticated {
                    // TODO: Implement favorites list
                    Text("Your favorites will appear here")
                        .foregroundColor(.gray)
                } else {
                    guestView
                }
            }
            .navigationTitle("Favorites")
        }
        .sheet(isPresented: $showAuth) {
            AuthenticationView()
                .environmentObject(authViewModel)
        }
    }
    
    private var guestView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.fill")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text("Sign in to view favorites")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create an account or sign in to save and view your favorite items")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            AppButton(
                title: "Sign In",
                icon: "person.fill",
                action: { showAuth = true }
            )
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .padding()
    }
}

#Preview {
    FavoritesView()
        .environmentObject(AuthViewModel())
} 