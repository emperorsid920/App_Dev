//
//  ProfileView.swift
//  Expense_Track
//
//  Created by Sid Kumar on 6/29/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Financial Information")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Monthly Salary")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("Enter your monthly salary", text: $profileViewModel.monthlySalary)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Monthly Savings Goal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("Enter your savings goal", text: $profileViewModel.monthlySavingsGoal)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Savings")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("Enter your current savings", text: $profileViewModel.currentSavings)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                Section(header: Text("Quick Actions")) {
                    AddToSavingsRow(profileViewModel: profileViewModel)
                }
                
                if profileViewModel.showError {
                    Section {
                        Text(profileViewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button("Sign Out") {
                        authViewModel.signOut()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await profileViewModel.saveProfile()
                            if !profileViewModel.showError {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!profileViewModel.canSaveProfile || profileViewModel.isLoading)
                }
            }
            .task {
                await profileViewModel.fetchProfile()
            }
        }
    }
}

struct AddToSavingsRow: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    @State private var savingsAmount = ""
    @State private var showingAddSavings = false
    
    var body: some View {
        Button(action: {
            showingAddSavings = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                Text("Add to Savings")
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .sheet(isPresented: $showingAddSavings) {
            NavigationView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount to Add")
                            .font(.headline)
                        TextField("Enter amount", text: $savingsAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding()
                    
                    Spacer()
                }
                .navigationTitle("Add to Savings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingAddSavings = false
                            savingsAmount = ""
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add") {
                            Task {
                                if let amount = Double(savingsAmount), amount > 0 {
                                    await profileViewModel.addToSavings(amount: amount)
                                    showingAddSavings = false
                                    savingsAmount = ""
                                }
                            }
                        }
                        .disabled(Double(savingsAmount) ?? 0 <= 0)
                    }
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
