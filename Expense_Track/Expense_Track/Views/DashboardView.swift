//
//  DashboardView.swift
//  
//
//  Created by Sid Kumar on 6/29/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var expenseViewModel = ExpenseViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showingAddExpense = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with total
                    VStack {
                        Text("Total Expenses")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("$\(expenseViewModel.totalExpenses, specifier: "%.2f")")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Recent Expenses
                    VStack(alignment: .leading) {
                        Text("Recent Expenses")
                            .font(.headline)
                        
                        if expenseViewModel.expenses.isEmpty {
                            Text("No expenses yet. Add your first expense!")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(expenseViewModel.expenses.prefix(5)) { expense in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(expense.category)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        if !expense.note.isEmpty {
                                            Text(expense.note)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text("$\(expense.amount, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .padding(.vertical, 8)
                                Divider()
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign Out") {
                        authViewModel.signOut()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddExpense = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await expenseViewModel.fetchExpenses()
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView(expenseViewModel: expenseViewModel)
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
