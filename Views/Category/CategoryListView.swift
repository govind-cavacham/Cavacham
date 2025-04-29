import SwiftUI

struct CategoryListView: View {
    @StateObject private var viewModel = CategoryViewModel()
    @State private var showAddCategory = false
    @State private var selectedCategory: Category?
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.categories.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "rectangle.3.group")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No Categories")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Add your first category to get started")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        ForEach(viewModel.categories) { category in
                            CategoryRow(category: category)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedCategory = category
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        selectedCategory = category
                                        showDeleteAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.loadCategories()
                    }
                }
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddCategory) {
                CategoryFormView(mode: .add)
                    .environmentObject(viewModel)
            }
            .sheet(item: $selectedCategory) { category in
                CategoryFormView(mode: .edit(category))
                    .environmentObject(viewModel)
            }
            .alert("Delete Category", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let category = selectedCategory {
                        Task {
                            await viewModel.deleteCategory(category)
                            selectedCategory = nil
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to delete this category? This action cannot be undone.")
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
        }
        .task {
            await viewModel.loadCategories()
        }
    }
}

struct CategoryRow: View {
    let category: Category
    
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: category.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                Text(category.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text("\(category.productCount)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    CategoryListView()
} 