//
//  ExpenseViewModel.swift
//  
//
//  Created by Sid Kumar on 6/29/25.
//

import Foundation
import SwiftUI

@MainActor
class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    
    // Form fields for adding expenses
    @Published var amount = ""
    @Published var selectedCategory = ExpenseCategory.categories.first ?? "Others"
    @Published var note = ""
    @Published var selectedDate = Date()
    
    private let firebaseManager = FirebaseManager.shared
    
    // MARK: - Computed Properties
    var isValidAmount: Bool {
        guard let amountValue = Double(amount) else { return false }
        return amountValue > 0
    }
    
    var canAddExpense: Bool {
        isValidAmount && !selectedCategory.isEmpty
    }
    
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var expensesByCategory: [String: Double] {
        Dictionary(grouping: expenses, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
    }
    
    // MARK: - Expense Actions
    func addExpense() async {
        guard canAddExpense,
              let amountValue = Double(amount),
              let userId = firebaseManager.currentUser?.uid else {
            showErrorMessage("Please check all fields")
            return
        }
        
        isLoading = true
        
        let expense = Expense(
                    amount: amountValue,
                    category: selectedCategory,
                    note: note,
                    date: selectedDate,
                    userId: userId
                )
        
        do {
            try await firebaseManager.addExpense(expense)
            await fetchExpenses()
            clearForm()
        } catch {
            showErrorMessage("Failed to add expense")
        }
        
        isLoading = false
    }
    
    func fetchExpenses() async {
        guard let userId = firebaseManager.currentUser?.uid else { return }
        
        isLoading = true
        
        do {
            expenses = try await firebaseManager.fetchExpenses(for: userId)
        } catch {
            showErrorMessage("Failed to load expenses")
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Methods
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    private func clearForm() {
        amount = ""
        note = ""
        selectedDate = Date()
        selectedCategory = ExpenseCategory.categories.first ?? "Others"
    }
}
