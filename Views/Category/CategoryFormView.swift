import SwiftUI
import PhotosUI

struct CategoryFormView: View {
    enum Mode {
        case add
        case edit(Category)
    }
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: CategoryViewModel
    @State private var name = ""
    @State private var description = ""
    @State private var imageUrl = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var isUploading = false
    
    let mode: Mode
    
    init(mode: Mode) {
        self.mode = mode
        
        switch mode {
        case .edit(let category):
            _name = State(initialValue: category.name)
            _description = State(initialValue: category.description)
            _imageUrl = State(initialValue: category.imageUrl)
        case .add:
            break
        }
    }
    
    // Computed properties to replace ternary operators
    private var navigationTitle: String {
        if case .add = mode {
            return "Add Category"
        } else {
            return "Edit Category"
        }
    }
    
    private var saveButtonLabel: String {
        if case .add = mode {
            return "Add"
        } else {
            return "Save"
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    if !imageUrl.isEmpty {
                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    PhotosPicker(selection: $selectedItem,
                                 matching: .images) {
                        Label(imageUrl.isEmpty ? "Select Image" : "Change Image",
                              systemImage: "photo")
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(saveButtonLabel) {
                        Task {
                            switch mode {
                            case .add:
                                await viewModel.addCategory(name, description: description, imageUrl: imageUrl)
                            case .edit(let category):
                                var updatedCategory = category
                                updatedCategory.name = name
                                updatedCategory.description = description
                                updatedCategory.imageUrl = imageUrl
                                await viewModel.updateCategory(updatedCategory)
                            }
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || description.isEmpty || imageUrl.isEmpty || isUploading)
                }
            }
            .onChange(of: selectedItem) { _ in
                guard let item = selectedItem else { return }
                isUploading = true
                
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        // Here you would typically upload the image data to your storage
                        // and get back a URL. For now, we'll just use a placeholder
                        imageUrl = "https://placeholder.com/image.jpg"
                    }
                    isUploading = false
                }
            }
        }
    }
}
