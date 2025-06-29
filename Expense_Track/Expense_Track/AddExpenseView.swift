//
//  AddExpenseView.swift
//  Expense_Track
//
//  Created by Sid Kumar on 6/29/25.
//

import SwiftUI

struct AddExpenseView: View {
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    TextField("Amount", text: $expenseViewModel.amount)
                        .keyboardType(.decimalPad)
                    
                    Picker("Category", selection: $expenseViewModel.selectedCategory) {
                        ForEach(ExpenseCategory.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    TextField("Note (Optional)", text: $expenseViewModel.note)
                    
                    DatePicker("Date", selection: $expenseViewModel.selectedDate, displayedComponents: .date)
                }
                
                if expenseViewModel.showError {
                    Section {
                        Text(expenseViewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Add Expense")
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
                            await expenseViewModel.addExpense()
                            if !expenseViewModel.showError {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!expenseViewModel.canAddExpense || expenseViewModel.isLoading)
                }
            }
        }
    }
}

#Preview {
    AddExpenseView(expenseViewModel: ExpenseViewModel())
}
