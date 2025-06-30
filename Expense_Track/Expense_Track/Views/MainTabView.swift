//
//  MainTabView.swift
//  Expense_Track
//
//  Created by Sid Kumar on 6/29/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var expenseViewModel = ExpenseViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    
    var body: some View {
        TabView {
            DashboardView(
                expenseViewModel: expenseViewModel,
                profileViewModel: profileViewModel
            )
            .tabItem {
                Image(systemName: "house.fill")
                Text("Dashboard")
            }
            
            BudgetReportView(
                expenseViewModel: expenseViewModel,
                profileViewModel: profileViewModel
            )
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("Reports")
            }
            
            ExpenseListView(expenses: expenseViewModel.expenses)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Expenses")
                }
        }
        .task {
            await expenseViewModel.fetchExpenses()
            await profileViewModel.fetchProfile()
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
