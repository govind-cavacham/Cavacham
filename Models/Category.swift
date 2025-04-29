import Foundation
import FirebaseFirestore

struct Category: Identifiable, Hashable, Codable {
    let id: String
    var name: String
    var description: String
    var imageUrl: String
    var productCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case imageUrl
        case productCount
    }
    
    init(id: String, name: String, description: String, imageUrl: String, productCount: Int = 0) {
        self.id = id
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
        self.productCount = productCount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
        self.productCount = try container.decode(Int.self, forKey: .productCount)
    }
    
    init?(document: QueryDocumentSnapshot) throws {
        let data = document.data()
        
        guard let name = data["name"] as? String,
              let description = data["description"] as? String,
              let imageUrl = data["imageUrl"] as? String else {
            return nil
        }
        
        self.id = document.documentID
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
        self.productCount = (data["productCount"] as? Int) ?? 0
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }
} 