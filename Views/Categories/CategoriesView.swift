import SwiftUI

struct CategoriesView: View {
    @StateObject private var viewModel = CategoryViewModel()
    @State private var searchText = ""
    @State private var showAddCategory = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return viewModel.categories
        }
        return viewModel.categories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.categories.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "rectangle.3.group")
                            .font(.system(size: 64))
                            .foregroundColor(.gray)
                        Text("No Categories Found")
                            .font(.headline)
                        Text("Add some categories to get started")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredCategories) { category in
                                NavigationLink(destination: CategoryDetailView(category: category)) {
                                    CategoryCard(category: category)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(12)
                                        .shadow(radius: 2)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Categories")
            .searchable(text: $searchText, prompt: "Search categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddCategory = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddCategory) {
                AddCategoryView(viewModel: viewModel)
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK", role: .cancel) {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
        }
        .onAppear {
            Task {
                await viewModel.loadCategories()
            }
        }
    }
}

#Preview {
    CategoriesView()
} 