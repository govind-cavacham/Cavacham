import Foundation
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

@MainActor
class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func loadCategories() async {
        isLoading = true
        error = nil
        
        do {
            let snapshot = try await db.collection("categories").getDocuments()
            categories = snapshot.documents.compactMap { document in
                try? Category(document: document)
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func addCategory(_ name: String, description: String, imageUrl: String) async {
        isLoading = true
        error = nil
        
        let data: [String: Any] = [
            "name": name,
            "description": description,
            "imageUrl": imageUrl,
            "productCount": 0
        ]
        
        do {
            let docRef = try await db.collection("categories").addDocument(data: data)
            if let category = try? Category(id: docRef.documentID,
                                         name: name,
                                         description: description,
                                         imageUrl: imageUrl,
                                         productCount: 0) {
                categories.append(category)
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func updateCategory(_ category: Category) async {
        isLoading = true
        error = nil
        
        let data: [String: Any] = [
            "name": category.name,
            "description": category.description,
            "imageUrl": category.imageUrl,
            "productCount": category.productCount
        ]
        
        do {
            try await db.collection("categories").document(category.id).updateData(data)
            if let index = categories.firstIndex(where: { $0.id == category.id }) {
                categories[index] = category
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func deleteCategory(_ category: Category) async {
        isLoading = true
        error = nil
        
        do {
            try await db.collection("categories").document(category.id).delete()
            categories.removeAll { $0.id == category.id }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func incrementProductCount(for categoryId: String) async {
        guard let index = categories.firstIndex(where: { $0.id == categoryId }) else { return }
        
        do {
            try await db.collection("categories").document(categoryId).updateData([
                "productCount": FieldValue.increment(Int64(1))
            ])
            categories[index].productCount += 1
        } catch {
            self.error = error
        }
    }
    
    func decrementProductCount(for categoryId: String) async {
        guard let index = categories.firstIndex(where: { $0.id == categoryId }) else { return }
        guard categories[index].productCount > 0 else { return }
        
        do {
            try await db.collection("categories").document(categoryId).updateData([
                "productCount": FieldValue.increment(Int64(-1))
            ])
            categories[index].productCount -= 1
        } catch {
            self.error = error
        }
    }
    
    func getCategoryById(_ id: String) -> Category? {
        return categories.first { $0.id == id }
    }
}

// Extension to convert Category to dictionary for Firestore
private extension Category {
    var dictionary: [String: Any] {
        [
            "name": name,
            "description": description,
            "imageUrl": imageUrl,
            "productCount": productCount
        ]
    }
} 
