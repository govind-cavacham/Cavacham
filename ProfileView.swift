//
//  ProfileView.swift
//  Cavacham
//
//  Created by Govind Pathak on 13/04/25.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("userEmail") var userEmail: String?
    @State private var animateIn = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("NeumorphicBackground")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
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
                            
                            Text(userEmail ?? "User")
                                .font(.system(.title, design: .rounded, weight: .bold))
                                .foregroundColor(Color("NeumorphicText"))
                            
                            Text("Crystal Enthusiast")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(Color("NeumorphicText"))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color("NeumorphicBackground"))
                                .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                        )
                        .scaleEffect(animateIn ? 1 : 0.8)
                        .animation(.spring(), value: animateIn)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Journey")
                                .font(.system(.title2, design: .rounded, weight: .bold))
                                .foregroundColor(Color("NeumorphicText"))
                            
                            Text("Track your crystal collection and chakra alignment.")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(Color("NeumorphicText"))
                            
                            HStack {
                                VStack {
                                    Text("Chakras Balanced")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(Color("NeumorphicText"))
                                    Text("4/7")
                                        .font(.system(.title3, design: .rounded, weight: .bold))
                                        .foregroundColor(Color("NeumorphicAccent"))
                                }
                                Spacer()
                                VStack {
                                    Text("Crystals Owned")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(Color("NeumorphicText"))
                                    Text("12")
                                        .font(.system(.title3, design: .rounded, weight: .bold))
                                        .foregroundColor(Color("NeumorphicAccent"))
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("NeumorphicBackground"))
                                    .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                            )
                            
                            // Navigation Link to ImageUploadView
                            NavigationLink(destination: ImageUploadView()) {
                                Text("Upload Images")
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
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 80)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundColor(Color("NeumorphicText"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        userEmail = nil
                    }) {
                        Text("Log Out")
                            .foregroundColor(Color("NeumorphicAccent"))
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("NeumorphicBackground"))
                                    .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                            )
                    }
                }
            }
            .onAppear { animateIn = true }
        }
    }
}

#Preview {
    ProfileView()
}
