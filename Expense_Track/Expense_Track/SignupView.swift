//
//  SignupView.swift
//  
//
//  Created by Sid Kumar on 6/29/25.
//

import SwiftUI

struct SignupView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack {
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Join us to start tracking your expenses")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Signup Form
                VStack(spacing: 16) {
                    TextField("Email", text: $authViewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $authViewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("Confirm Password", text: $authViewModel.confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Validation Messages
                    VStack(alignment: .leading, spacing: 4) {
                        if !authViewModel.email.isEmpty && !authViewModel.isValidEmail {
                            Text("Please enter a valid email")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        if !authViewModel.password.isEmpty && !authViewModel.isValidPassword {
                            Text("Password must be at least 6 characters")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        if !authViewModel.confirmPassword.isEmpty && !authViewModel.passwordsMatch {
                            Text("Passwords do not match")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        if authViewModel.showError {
                            Text(authViewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    
                    Button(action: {
                        Task {
                            await authViewModel.signUp()
                        }
                    }) {
                        HStack {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text("Sign Up")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(authViewModel.canSignUp ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(!authViewModel.canSignUp || authViewModel.isLoading)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Back to Login
                Button(action: {
                    dismiss()
                }) {
                    Text("Already have an account? Sign In")
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 50)
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    SignupView()
}
