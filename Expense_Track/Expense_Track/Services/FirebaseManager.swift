//
//  FirebaseManager.swift (Updated)
//  Expense_Track
//
//  Created by Sid Kumar on 6/29/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    
    private init() {
        // Check if user is already logged in
        if let user = auth.currentUser {
            self.currentUser = user
            self.isAuthenticated = true
        }
        
        // Listen for auth state changes
        auth.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    // MARK: - Authentication
    func signUp(email: String, password: String) async throws {
        try await auth.createUser(withEmail: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws {
        try await auth.signIn(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    // MARK: - Expense Operations
    func addExpense(_ expense: Expense) async throws {
        try firestore.collection("expenses").document().setData(from: expense)
    }
    
    func fetchExpenses(for userId: String) async throws -> [Expense] {
        let snapshot = try await firestore
            .collection("expenses")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return try snapshot.documents.compactMap { document in
            try document.data(as: Expense.self)
        }
    }
    
    // MARK: - User Profile Operations
    func createUserProfile(_ profile: UserProfile) async throws {
        try firestore.collection("userProfiles").document().setData(from: profile)
    }
    
    func fetchUserProfile(for userId: String) async throws -> UserProfile? {
        let snapshot = try await firestore
            .collection("userProfiles")
            .whereField("userId", isEqualTo: userId)
            .limit(to: 1)
            .getDocuments()
        
        guard let document = snapshot.documents.first else {
            return nil
        }
        
        return try document.data(as: UserProfile.self)
    }
    
    func updateUserProfile(_ profile: UserProfile) async throws {
        guard let profileId = profile.id else {
            throw NSError(domain: "ProfileError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Profile ID is missing"])
        }
        
        try firestore.collection("userProfiles").document(profileId).setData(from: profile)
    }
}
