import SwiftUI
import PhotosUI

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CategoryViewModel
    
    @State private var name = ""
    @State private var description = ""
    @State private var imageUrl = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var isUploading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Details")) {
                    TextField("Name", text: $name)
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Category Image")) {
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        if !imageUrl.isEmpty {
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text("Select Image")
                                    .foregroundColor(.gray)
                            }
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(Color.appSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                
                Section {
                    Button(action: saveCategory) {
                        if isUploading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Save Category")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(isUploading || name.isEmpty || description.isEmpty || imageUrl.isEmpty)
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedImage) { _ in
                Task {
                    await uploadImage()
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func uploadImage() async {
        guard let selectedImage = selectedImage else { return }
        
        isUploading = true
        
        do {
            let imageData = try await selectedImage.loadTransferable(type: Data.self)
            guard let imageData = imageData else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load image data"])
            }
            
            // Here you would typically upload the image to your storage service
            // For now, we'll just simulate it with a delay
            try await Task.sleep(nanoseconds: 2 * 1_000_000_000) // 2 seconds
            
            // Set a dummy URL for preview purposes
            imageUrl = "https://firebasestorage.googleapis.com/example/image.jpg"
            
            isUploading = false
        } catch {
            isUploading = false
            showError = true
            errorMessage = error.localizedDescription
        }
    }
    
    private func saveCategory() {
        Task {
            await viewModel.addCategory(name, description: description, imageUrl: imageUrl)
            dismiss()
        }
    }
}
