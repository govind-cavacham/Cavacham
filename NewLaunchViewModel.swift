//
//  NewLaunchViewModel.swift
//  Cavacham
//
//  Created by Govind Pathak on 13/04/25.
//

import Foundation
import FirebaseFirestore

struct NewLaunch: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var subtitle: String?
    var description: [String]
    var howToUse: [String]?
    var impact: [String]?
    var image: String?
    var images: [String]?
    var price: Double?
    var timestamp: Date

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, description, howToUse, impact, image, images, price, timestamp
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)

        if let descriptionArray = try? container.decode([String].self, forKey: .description) {
            description = descriptionArray
        } else if let descriptionString = try? container.decode(String.self, forKey: .description) {
            description = [descriptionString]
        } else {
            description = []
        }

        if let howToUseArray = try? container.decode([String].self, forKey: .howToUse) {
            howToUse = howToUseArray
        } else if let howToUseString = try? container.decode(String.self, forKey: .howToUse) {
            howToUse = [howToUseString]
        } else {
            howToUse = []
        }

        if let impactArray = try? container.decode([String].self, forKey: .impact) {
            impact = impactArray
        } else if let impactString = try? container.decode(String.self, forKey: .impact) {
            impact = [impactString]
        } else {
            impact = []
        }

        image = try container.decodeIfPresent(String.self, forKey: .image)
        images = try container.decodeIfPresent([String].self, forKey: .images)
        price = try container.decodeIfPresent(Double.self, forKey: .price)
        let timestampValue = try container.decodeIfPresent(Timestamp.self, forKey: .timestamp)
        timestamp = timestampValue?.dateValue() ?? Date()
    }

    init(id: String?, title: String, subtitle: String? = nil, description: [String], howToUse: [String]? = nil, impact: [String]? = nil, image: String? = nil, images: [String]? = nil, price: Double? = nil, timestamp: Date) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.howToUse = howToUse ?? []
        self.impact = impact ?? []
        self.image = image
        self.images = images
        self.price = price
        self.timestamp = timestamp
    }
}

@MainActor
class NewLaunchViewModel: ObservableObject {
    @Published var launches: [NewLaunch] = []
    @Published var errorMessage: String?

    func fetchNewLaunches() {
        Firestore.firestore().collection("new_launches").addSnapshotListener { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to load launches: \(error.localizedDescription)"
                print("Error fetching new launches: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                self.errorMessage = "No launches found."
                print("No documents in new_launches collection")
                return
            }

            self.launches = documents.compactMap { doc -> NewLaunch? in
                do {
                    var launch = try doc.data(as: NewLaunch.self)
                    launch.id = doc.documentID
                    print("Fetched launch: \(launch.title), ID: \(launch.id ?? "nil")")
                    return launch
                } catch {
                    print("Error decoding launch \(doc.documentID): \(error)")
                    return nil
                }
            }.sorted { $0.timestamp > $1.timestamp }
            
            if self.launches.isEmpty {
                print("No launches decoded successfully. Check Firestore data structure.")
            }
        }
    }
    
    func fetchNewLaunchesAsync() async {
        do {
            let snapshot = try await Firestore.firestore().collection("new_launches").getDocuments()
            let documents = snapshot.documents
            
            self.launches = documents.compactMap { doc -> NewLaunch? in
                do {
                    var launch = try doc.data(as: NewLaunch.self)
                    launch.id = doc.documentID
                    print("Fetched launch async: \(launch.title), ID: \(launch.id ?? "nil")")
                    return launch
                } catch {
                    print("Error decoding launch \(doc.documentID): \(error)")
                    return nil
                }
            }.sorted { $0.timestamp > $1.timestamp }
            
            if self.launches.isEmpty {
                self.errorMessage = "No launches found."
                print("No launches decoded successfully. Check Firestore data structure.")
            }
        } catch {
            self.errorMessage = "Failed to load launches: \(error.localizedDescription)"
            print("Error fetching launches async: \(error)")
        }
    }
}
