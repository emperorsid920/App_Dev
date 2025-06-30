//
//  UserProfile.swift
//  Expense_Track
//
//  Created by Sid Kumar on 6/29/25.
//

import Foundation
import FirebaseFirestoreSwift

struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var monthlySalary: Double
    var monthlySavingsGoal: Double
    var currentSavings: Double
    var createdAt: Date
    var updatedAt: Date
    
    init(userId: String, monthlySalary: Double = 0, monthlySavingsGoal: Double = 0, currentSavings: Double = 0) {
        self.userId = userId
        self.monthlySalary = monthlySalary
        self.monthlySavingsGoal = monthlySavingsGoal
        self.currentSavings = currentSavings
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
