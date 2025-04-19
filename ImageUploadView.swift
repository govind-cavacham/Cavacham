//
//  ImageUploadView.swift
//  Cavacham
//
//  Created by Grok on 15/04/25.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import PhotosUI

struct ImageUploadView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItemType: String = "Crystal" // "Crystal" or "New Launch"
    @State private var selectedItemId: String = ""
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var isUploading = false
    @State private var uploadError: String? = nil
    @State private var uploadSuccess = false
    
    // Firestore references
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // Lists for selection
    private let itemTypes = ["Crystal", "New Launch"]
    private let crystals = [
        "selenite", "blacktourmaline", "greenaventurine", "citrine", "7chakras",
        "amethyst", "carnelian", "lapislazuli", "moonstone", "pyrite",
        "rosequartz", "sphatic", "sunstone", "tigereye", "turquoise"
    ]
    private let newLaunches = [
        "DIM3i1CseRguJH3yo2k", "F2i1xOsO0wN5BjY9Pw8", "MMf9V9V0kzyiHVf1MQAd",
        "UU16vWCAO0nkVFFPGlI6", "Udtpo0f1UQa7DVOql96M", "iGYGJK3vpgSJPFpja9c7",
        "ohEnm8dZEKQ5zuKSCiY5"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("NeumorphicBackground")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Title
                    Text("Upload Image")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundColor(Color("NeumorphicText"))
                    
                    // Item Type Picker
                    Picker("Item Type", selection: $selectedItemType) {
                        ForEach(itemTypes, id: \.self) { type in
                            Text(type)
                                .foregroundColor(Color("NeumorphicText"))
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Item ID Picker
                    Picker("Select Item", selection: $selectedItemId) {
                        if selectedItemType == "Crystal" {
                            ForEach(crystals, id: \.self) { crystalId in
                                Text(crystalId.capitalized)
                                    .foregroundColor(Color("NeumorphicText"))
                            }
                        } else {
                            ForEach(newLaunches, id: \.self) { launchId in
                                Text(launchId)
                                    .foregroundColor(Color("NeumorphicText"))
                            }
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("NeumorphicBackground"))
                            .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                    )
                    .padding(.horizontal)
                    
                    // Image Picker Button
                    PhotosPicker("Select Image", selection: $selectedPhoto, matching: .images)
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
                        .padding(.horizontal)
                        .onChange(of: selectedPhoto) { newPhoto in
                            Task {
                                if let data = try? await newPhoto?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                }
                            }
                        }
                    
                    // Image Preview
                    if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                    }
                    
                    // Upload Button
                    Button(action: uploadImage) {
                        if isUploading {
                            ProgressView()
                                .tint(Color("NeumorphicAccent"))
                        } else {
                            Text(uploadSuccess ? "Uploaded!" : "Upload")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("NeumorphicBackground"))
                                        .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                                )
                                .foregroundColor(uploadSuccess ? .green : Color("NeumorphicAccent"))
                        }
                    }
                    .disabled(isUploading || selectedImageData == nil || selectedItemId.isEmpty)
                    .padding(.horizontal)
                    
                    // Error Message
                    if let error = uploadError {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("NeumorphicBackground"))
                                    .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                            )
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color("NeumorphicText"))
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(Color("NeumorphicBackground"))
                                    .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                            )
                    }
                }
            }
        }
    }
    
    private func uploadImage() {
        guard let imageData = selectedImageData, !selectedItemId.isEmpty else {
            uploadError = "Please select an image and an item."
            return
        }
        
        isUploading = true
        uploadError = nil
        uploadSuccess = false
        
        // Determine the storage path
        let folder = selectedItemType == "Crystal" ? "crystal_images" : "launch_images"
        let fileName = "\(selectedItemId)_\(Int(Date().timeIntervalSince1970)).jpg"
        let storageRef = storage.reference().child("\(folder)/\(fileName)")
        
        // Upload the image to Firebase Storage
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                DispatchQueue.main.async {
                    isUploading = false
                    uploadError = "Failed to upload image: \(error.localizedDescription)"
                }
                return
            }
            
            // Get the download URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    DispatchQueue.main.async {
                        isUploading = false
                        uploadError = "Failed to get download URL: \(error.localizedDescription)"
                    }
                    return
                }
                
                guard let downloadURL = url?.absoluteString else {
                    DispatchQueue.main.async {
                        isUploading = false
                        uploadError = "Failed to get download URL."
                    }
                    return
                }
                
                // Update Firestore with the image URL
                let collectionName = selectedItemType == "Crystal" ? "all_crystals" : "new_launches"
                let docRef = db.collection(collectionName).document(selectedItemId)
                
                if selectedItemType == "Crystal" {
                    docRef.updateData(["imageURLs": [downloadURL]]) { error in
                        DispatchQueue.main.async {
                            isUploading = false
                            if let error = error {
                                uploadError = "Failed to update Firestore: \(error.localizedDescription)"
                            } else {
                                uploadSuccess = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    uploadSuccess = false
                                    selectedPhoto = nil
                                    selectedImageData = nil
                                }
                            }
                        }
                    }
                } else {
                    docRef.updateData([
                        "image": downloadURL,
                        "images": [downloadURL]
                    ]) { error in
                        DispatchQueue.main.async {
                            isUploading = false
                            if let error = error {
                                uploadError = "Failed to update Firestore: \(error.localizedDescription)"
                            } else {
                                uploadSuccess = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    uploadSuccess = false
                                    selectedPhoto = nil
                                    selectedImageData = nil
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ImageUploadView()
}
