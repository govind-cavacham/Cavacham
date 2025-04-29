import SwiftUI

struct CategoryCard: View {
    let category: Category
    
    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: category.imageUrl)) { phase in
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
            .frame(width: 120, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(category.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 120)
    }
}

#Preview {
    CategoryCard(category: Category(
        id: "1",
        name: "Electronics",
        description: "Electronic gadgets and accessories",
        imageUrl: "https://example.com/electronics.jpg",
        productCount: 0
    ))
} 