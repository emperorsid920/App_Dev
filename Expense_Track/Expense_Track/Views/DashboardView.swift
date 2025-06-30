//
//  DashboardView.swift (Updated)
//  Expense_Track
//
//  Created by Sid Kumar on 6/29/25.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showingAddExpense = false
    @State private var showingProfile = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Financial Overview Card
                    VStack(spacing: 16) {
                        Text("Financial Overview")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            FinancialMetricCard(
                                title: "Monthly Income",
                                value: profileViewModel.monthlySalaryValue,
                                color: .green
                            )
                            
                            FinancialMetricCard(
                                title: "Total Expenses",
                                value: expenseViewModel.totalExpenses,
                                color: .red
                            )
                        }
                        
                        HStack {
                            FinancialMetricCard(
                                title: "Savings Goal",
                                value: profileViewModel.monthlySavingsGoalValue,
                                color: .blue
                            )
                            
                            FinancialMetricCard(
                                title: "Current Savings",
                                value: profileViewModel.currentSavingsValue,
                                color: .orange
                            )
                        }
                        
                        // Financial Health Indicator
                        if profileViewModel.monthlySalaryValue > 0 {
                            FinancialHealthIndicator(
                                salary: profileViewModel.monthlySalaryValue,
                                expenses: expenseViewModel.totalExpenses,
                                savingsGoal: profileViewModel.monthlySavingsGoalValue
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Recent Expenses
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Expenses")
                                .font(.headline)
                            Spacer()
                            if !expenseViewModel.expenses.isEmpty {
                                NavigationLink("View All") {
                                    ExpenseListView(expenses: expenseViewModel.expenses)
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            }
                        }
                        
                        if expenseViewModel.expenses.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "chart.bar.doc.horizontal")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                Text("No expenses yet")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("Add your first expense to get started!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        } else {
                            ForEach(expenseViewModel.expenses.prefix(5)) { expense in
                                ExpenseRowView(expense: expense)
                                if expense.id != expenseViewModel.expenses.prefix(5).last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding()
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
                    Button(action: {
                        showingProfile = true
                    }) {
                        Image(systemName: "person.circle")
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
                // Data loading is now handled by MainTabView
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView(expenseViewModel: expenseViewModel)
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
        }
    }
}

struct FinancialMetricCard: View {
    let title: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("$\(value, specifier: "%.2f")")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct FinancialHealthIndicator: View {
    let salary: Double
    let expenses: Double
    let savingsGoal: Double
    
    private var remaining: Double {
        salary - expenses
    }
    
    private var savingsProgress: Double {
        guard savingsGoal > 0 else { return 0 }
        return min(remaining / savingsGoal, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Monthly Budget Status")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                Text("Remaining: $\(remaining, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(remaining >= 0 ? .green : .red)
                
                Spacer()
                
                if savingsGoal > 0 {
                    Text("Savings Progress: \(savingsProgress * 100, specifier: "%.0f")%")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            if savingsGoal > 0 {
                ProgressView(value: savingsProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: savingsProgress >= 1.0 ? .green : .blue))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct ExpenseRowView: View {
    let expense: Expense
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.category)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if !expense.note.isEmpty {
                    Text(expense.note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Text(expense.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$\(expense.amount, specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.red)
        }
        .padding(.vertical, 4)
    }
}

struct ExpenseListView: View {
    let expenses: [Expense]
    
    var body: some View {
        List(expenses) { expense in
            ExpenseRowView(expense: expense)
        }
        .navigationTitle("All Expenses")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
