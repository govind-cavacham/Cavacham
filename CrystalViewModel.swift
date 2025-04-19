//
//  CrystalViewModel.swift
//  Cavacham
//
//  Created by Govind Pathak on 13/04/25.
//

import Foundation
import FirebaseFirestore

@MainActor
class CrystalViewModel: ObservableObject {
    @Published var crystals: [Crystal] = []
    @Published var errorMessage: String?

    func fetchCrystals() {
        Firestore.firestore().collection("all_crystals").addSnapshotListener { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to load crystals: \(error.localizedDescription)"
                print("Error fetching crystals: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                self.errorMessage = "No crystals found."
                print("No documents in all_crystals collection")
                return
            }

            self.crystals = documents.compactMap { doc -> Crystal? in
                do {
                    var crystal = try doc.data(as: Crystal.self)
                    crystal.id = doc.documentID
                    print("Fetched crystal: \(crystal.name), ID: \(crystal.id)")
                    return crystal
                } catch {
                    print("Error decoding crystal \(doc.documentID): \(error)")
                    return nil
                }
            }.sorted { ($0.timestamp ?? Date()) > ($1.timestamp ?? Date()) }
            
            if self.crystals.isEmpty {
                print("No crystals decoded successfully. Check Firestore data structure.")
            }
        }
    }
    
    func fetchCrystalsAsync() async {
        do {
            let snapshot = try await Firestore.firestore().collection("all_crystals").getDocuments()
            let documents = snapshot.documents
            
            self.crystals = documents.compactMap { doc -> Crystal? in
                do {
                    var crystal = try doc.data(as: Crystal.self)
                    crystal.id = doc.documentID
                    print("Fetched crystal async: \(crystal.name), ID: \(crystal.id)")
                    return crystal
                } catch {
                    print("Error decoding crystal \(doc.documentID): \(error)")
                    return nil
                }
            }.sorted { ($0.timestamp ?? Date()) > ($1.timestamp ?? Date()) }
            
            if self.crystals.isEmpty {
                self.errorMessage = "No crystals found."
                print("No crystals decoded successfully. Check Firestore data structure.")
            }
        } catch {
            self.errorMessage = "Failed to load crystals: \(error.localizedDescription)"
            print("Error fetching crystals async: \(error)")
        }
    }
}
