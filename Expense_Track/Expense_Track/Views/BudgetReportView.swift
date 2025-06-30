//
//  BudgetReportView.swift
//  Expense_Track
//
//  Created by Sid Kumar on 6/29/25.
//

import SwiftUI
import Charts

struct BudgetReportView: View {
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @State private var selectedTimeFrame: TimeFrame = .thisMonth
    
    enum TimeFrame: String, CaseIterable {
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case last30Days = "Last 30 Days"
        case last90Days = "Last 90 Days"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Frame Picker
                    Picker("Time Frame", selection: $selectedTimeFrame) {
                        ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                            Text(timeFrame.rawValue).tag(timeFrame)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Budget Overview Card
                    BudgetOverviewCard(
                        profileViewModel: profileViewModel,
                        expenseViewModel: expenseViewModel,
                        timeFrame: selectedTimeFrame
                    )
                    
                    // Expense by Category Chart
                    ExpenseByCategoryChart(
                        expenses: filteredExpenses,
                        timeFrame: selectedTimeFrame
                    )
                    
                    // Spending Trend Chart
                    SpendingTrendChart(
                        expenses: filteredExpenses,
                        timeFrame: selectedTimeFrame
                    )
                    
                    // Category Breakdown List
                    CategoryBreakdownList(
                        expensesByCategory: expensesByCategory
                    )
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Budget Report")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var filteredExpenses: [Expense] {
        let calendar = Calendar.current
        let now = Date()
        
        return expenseViewModel.expenses.filter { expense in
            switch selectedTimeFrame {
            case .thisWeek:
                return calendar.isDate(expense.date, equalTo: now, toGranularity: .weekOfYear)
            case .thisMonth:
                return calendar.isDate(expense.date, equalTo: now, toGranularity: .month)
            case .last30Days:
                return expense.date >= calendar.date(byAdding: .day, value: -30, to: now) ?? now
            case .last90Days:
                return expense.date >= calendar.date(byAdding: .day, value: -90, to: now) ?? now
            }
        }
    }
    
    private var expensesByCategory: [String: Double] {
        Dictionary(grouping: filteredExpenses, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
            .sorted { $0.value > $1.value }
            .reduce(into: [:]) { result, pair in
                result[pair.key] = pair.value
            }
    }
}

struct BudgetOverviewCard: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var expenseViewModel: ExpenseViewModel
    let timeFrame: BudgetReportView.TimeFrame
    
    private var totalExpenses: Double {
        // Calculate based on time frame
        return expenseViewModel.totalExpenses // Simplified for now
    }
    
    private var budgetStatus: (remaining: Double, percentage: Double, isOverBudget: Bool) {
        let income = profileViewModel.monthlySalaryValue
        let remaining = income - totalExpenses
        let percentage = income > 0 ? (totalExpenses / income) * 100 : 0
        
        return (remaining, percentage, remaining < 0)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Budget Overview")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Income")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(profileViewModel.monthlySalaryValue, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Spent")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(totalExpenses, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Remaining")
                        .font(.subheadline)
                    Spacer()
                    Text("$\(budgetStatus.remaining, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(budgetStatus.isOverBudget ? .red : .green)
                }
                
                ProgressView(value: min(budgetStatus.percentage / 100, 1.0))
                    .progressViewStyle(LinearProgressViewStyle(tint: budgetStatus.isOverBudget ? .red : .blue))
                
                Text("\(budgetStatus.percentage, specifier: "%.1f")% of income spent")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ExpenseByCategoryChart: View {
    let expenses: [Expense]
    let timeFrame: BudgetReportView.TimeFrame
    
    private var chartData: [CategoryData] {
        let grouped = Dictionary(grouping: expenses, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
            .sorted { $0.value > $1.value }
            .prefix(6) // Show top 6 categories
        
        return grouped.map { CategoryData(category: $0.key, amount: $0.value) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Expenses by Category")
                .font(.headline)
            
            if chartData.isEmpty {
                Text("No expenses for selected period")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                // Using BarMark instead of SectorMark for better compatibility
                Chart(chartData) { data in
                    BarMark(
                        x: .value("Amount", data.amount),
                        y: .value("Category", data.category)
                    )
                    .foregroundStyle(by: .value("Category", data.category))
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .chartLegend(position: .bottom, alignment: .center)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .currency(code: "USD"))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SpendingTrendChart: View {
    let expenses: [Expense]
    let timeFrame: BudgetReportView.TimeFrame
    
    private var chartData: [DailySpending] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: expenses) { expense in
            calendar.startOfDay(for: expense.date)
        }
        
        return grouped.map { date, expenses in
            DailySpending(
                date: date,
                amount: expenses.reduce(0) { $0 + $1.amount }
            )
        }
        .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending Trend")
                .font(.headline)
            
            if chartData.isEmpty {
                Text("No spending data for selected period")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                Chart(chartData) { data in
                    LineMark(
                        x: .value("Date", data.date),
                        y: .value("Amount", data.amount)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    AreaMark(
                        x: .value("Date", data.date),
                        y: .value("Amount", data.amount)
                    )
                    .foregroundStyle(.blue.opacity(0.3))
                }
                .frame(height: 150)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .currency(code: "USD"))
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CategoryBreakdownList: View {
    let expensesByCategory: [String: Double]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category Breakdown")
                .font(.headline)
            
            if expensesByCategory.isEmpty {
                Text("No expenses to show")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(Array(expensesByCategory.keys).sorted { expensesByCategory[$0] ?? 0 > expensesByCategory[$1] ?? 0 }, id: \.self) { category in
                    let amount = expensesByCategory[category] ?? 0
                    let percentage = expensesByCategory.values.reduce(0, +) > 0 ? (amount / expensesByCategory.values.reduce(0, +)) * 100 : 0
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(category)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("\(percentage, specifier: "%.1f")% of total")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("$\(amount, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .padding(.vertical, 4)
                    
                    if category != Array(expensesByCategory.keys).last {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Alternative Pie Chart View (if you want to keep pie chart functionality)
struct AlternativePieChart: View {
    let chartData: [CategoryData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Expenses by Category")
                .font(.headline)
            
            if chartData.isEmpty {
                Text("No expenses for selected period")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    // Simple visual representation using bars
                    let total = chartData.reduce(0) { $0 + $1.amount }
                    
                    ForEach(chartData.prefix(5)) { data in
                        let percentage = total > 0 ? data.amount / total : 0
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(data.category)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                Text("$\(data.amount, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            
                            GeometryReader { geometry in
                                HStack(spacing: 0) {
                                    Rectangle()
                                        .fill(colorForIndex(chartData.firstIndex(where: { $0.id == data.id }) ?? 0))
                                        .frame(width: geometry.size.width * percentage)
                                    
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: geometry.size.width * (1 - percentage))
                                }
                            }
                            .frame(height: 8)
                            .cornerRadius(4)
                            
                            Text("\(percentage * 100, specifier: "%.1f")% of total")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func colorForIndex(_ index: Int) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink]
        return colors[index % colors.count]
    }
}

// MARK: - Data Models for Charts
struct CategoryData: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
}

struct DailySpending: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
}

struct BudgetReportView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetReportView(
            expenseViewModel: ExpenseViewModel(),
            profileViewModel: ProfileViewModel()
        )
    }
}
