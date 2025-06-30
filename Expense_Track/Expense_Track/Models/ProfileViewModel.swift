//
//  ProfileViewModel.swift
//  Expense_Track
//
//  Created by Sid Kumar on 6/29/25.
//

import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    
    // Form fields
    @Published var monthlySalary = ""
    @Published var monthlySavingsGoal = ""
    @Published var currentSavings = ""
    
    private let firebaseManager = FirebaseManager.shared
    
    // MARK: - Computed Properties
    var isValidSalary: Bool {
        guard let salaryValue = Double(monthlySalary) else { return false }
        return salaryValue >= 0
    }
    
    var isValidSavingsGoal: Bool {
        guard let savingsGoalValue = Double(monthlySavingsGoal) else { return false }
        return savingsGoalValue >= 0
    }
    
    var isValidCurrentSavings: Bool {
        guard let currentSavingsValue = Double(currentSavings) else { return false }
        return currentSavingsValue >= 0
    }
    
    var canSaveProfile: Bool {
        isValidSalary && isValidSavingsGoal && isValidCurrentSavings
    }
    
    var monthlySalaryValue: Double {
        userProfile?.monthlySalary ?? 0
    }
    
    var monthlySavingsGoalValue: Double {
        userProfile?.monthlySavingsGoal ?? 0
    }
    
    var currentSavingsValue: Double {
        userProfile?.currentSavings ?? 0
    }
    
    // MARK: - Profile Actions
    func fetchProfile() async {
        guard let userId = firebaseManager.currentUser?.uid else { return }
        
        isLoading = true
        
        do {
            userProfile = try await firebaseManager.fetchUserProfile(for: userId)
            updateFormFields()
        } catch {
            // If profile doesn't exist, create a new one
            await createInitialProfile()
        }
        
        isLoading = false
    }
    
    func saveProfile() async {
        guard canSaveProfile,
              let userId = firebaseManager.currentUser?.uid,
              let salaryValue = Double(monthlySalary),
              let savingsGoalValue = Double(monthlySavingsGoal),
              let currentSavingsValue = Double(currentSavings) else {
            showErrorMessage("Please check all fields")
            return
        }
        
        isLoading = true
        
        do {
            if var existingProfile = userProfile {
                // Update existing profile
                existingProfile.monthlySalary = salaryValue
                existingProfile.monthlySavingsGoal = savingsGoalValue
                existingProfile.currentSavings = currentSavingsValue
                existingProfile.updatedAt = Date()
                
                try await firebaseManager.updateUserProfile(existingProfile)
                userProfile = existingProfile
            } else {
                // Create new profile
                let newProfile = UserProfile(
                    userId: userId,
                    monthlySalary: salaryValue,
                    monthlySavingsGoal: savingsGoalValue,
                    currentSavings: currentSavingsValue
                )
                
                try await firebaseManager.createUserProfile(newProfile)
                userProfile = newProfile
            }
        } catch {
            showErrorMessage("Failed to save profile")
        }
        
        isLoading = false
    }
    
    func addToSavings(amount: Double) async {
        guard let userId = firebaseManager.currentUser?.uid,
              var profile = userProfile else { return }
        
        isLoading = true
        
        do {
            profile.currentSavings += amount
            profile.updatedAt = Date()
            
            try await firebaseManager.updateUserProfile(profile)
            userProfile = profile
            updateFormFields()
        } catch {
            showErrorMessage("Failed to add to savings")
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Methods
    private func createInitialProfile() async {
        guard let userId = firebaseManager.currentUser?.uid else { return }
        
        let newProfile = UserProfile(userId: userId)
        
        do {
            try await firebaseManager.createUserProfile(newProfile)
            userProfile = newProfile
            updateFormFields()
        } catch {
            showErrorMessage("Failed to create profile")
        }
    }
    
    private func updateFormFields() {
        guard let profile = userProfile else { return }
        
        monthlySalary = String(format: "%.2f", profile.monthlySalary)
        monthlySavingsGoal = String(format: "%.2f", profile.monthlySavingsGoal)
        currentSavings = String(format: "%.2f", profile.currentSavings)
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}
