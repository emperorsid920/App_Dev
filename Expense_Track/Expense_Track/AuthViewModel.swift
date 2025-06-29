//
//  AuthViewModel.swift
//  
//
//  Created by Sid Kumar on 6/29/25.
//

import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    
    private let firebaseManager = FirebaseManager.shared
    
    // MARK: - Validation
    var isValidEmail: Bool {
        email.contains("@") && email.contains(".")
    }
    
    var isValidPassword: Bool {
        password.count >= 6
    }
    
    var passwordsMatch: Bool {
        password == confirmPassword
    }
    
    var canSignIn: Bool {
        isValidEmail && isValidPassword
    }
    
    var canSignUp: Bool {
        isValidEmail && isValidPassword && passwordsMatch
    }
    
    // MARK: - Authentication Actions
    func signIn() async {
        guard canSignIn else {
            showErrorMessage("Please check your email and password")
            return
        }
        
        isLoading = true
        
        do {
            try await firebaseManager.signIn(email: email, password: password)
            clearFields()
        } catch {
            showErrorMessage("Invalid email or password")
        }
        
        isLoading = false
    }
    
    func signUp() async {
        guard canSignUp else {
            showErrorMessage("Please check all fields")
            return
        }
        
        isLoading = true
        
        do {
            try await firebaseManager.signUp(email: email, password: password)
            clearFields()
        } catch {
            showErrorMessage("Failed to create account. Email may already be in use.")
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try firebaseManager.signOut()
            clearFields()
        } catch {
            showErrorMessage("Failed to sign out")
        }
    }
    
    // MARK: - Helper Methods
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    private func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
        errorMessage = ""
        showError = false
    }
}
