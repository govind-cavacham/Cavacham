//
//  WelcomeAuthView.swift
//  Cavacham
//
//  Created by Govind Pathak on 13/04/25.
//

import SwiftUI

struct WelcomeAuthView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color("NeumorphicBackground")
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Image(systemName: "sparkles")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color("NeumorphicAccent"))
                        .padding(20)
                        .background(
                            Circle()
                                .fill(Color("NeumorphicBackground"))
                                .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                        )
                    
                    Text("Welcome to Cavacham")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundColor(Color("NeumorphicText"))
                    
                    Text("Discover the power of crystals")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(Color("NeumorphicText"))
                    
                    VStack(spacing: 12) {
                        NavigationLink(destination: LoginView()) {
                            Text("Log In")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("NeumorphicBackground"))
                                        .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                                )
                                .foregroundColor(Color("NeumorphicAccent"))
                        }
                        
                        NavigationLink(destination: SignupView()) {
                            Text("Sign Up")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("NeumorphicBackground"))
                                        .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                                )
                                .foregroundColor(Color("NeumorphicText"))
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("NeumorphicBackground"))
                        .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                )
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    WelcomeAuthView()
}
