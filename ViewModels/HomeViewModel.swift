import SwiftUI
import FirebaseFirestore

class HomeViewModel: ObservableObject {
    @Published var featuredProducts: [Product] = []
    @Published var categories: [Category] = []
    @Published var newArrivals: [Product] = []
    @Published var popularProducts: [Product] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let db = Firestore.firestore()
    
    @MainActor
    func loadData() async {
        isLoading = true
        
        do {
            // Load categories
            let categoriesSnapshot = try await db.collection("categories").getDocuments()
            categories = categoriesSnapshot.documents.compactMap { document in
                try? document.data(as: Category.self)
            }
            
            // Load featured products
            let featuredSnapshot = try await db.collection("products")
                .whereField("isFeatured", isEqualTo: true)
                .limit(to: 5)
                .getDocuments()
            featuredProducts = featuredSnapshot.documents.compactMap { document in
                try? document.data(as: Product.self)
            }
            
            // Load new arrivals
            let newArrivalsSnapshot = try await db.collection("products")
                .order(by: "createdAt", descending: true)
                .limit(to: 5)
                .getDocuments()
            newArrivals = newArrivalsSnapshot.documents.compactMap { document in
                try? document.data(as: Product.self)
            }
            
            // Load popular products
            let popularSnapshot = try await db.collection("products")
                .order(by: "popularity", descending: true)
                .limit(to: 6)
                .getDocuments()
            popularProducts = popularSnapshot.documents.compactMap { document in
                try? document.data(as: Product.self)
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
} 