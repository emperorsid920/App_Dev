/
//  Expense.swift
//  Expense_Track
//
//  Created by Sid Kumar on 6/29/25.
//

import Foundation
import FirebaseFirestoreSwift

struct Expense: Identifiable, Codable {
    @DocumentID var id: String?
    var amount: Double
    var category: String
    var note: String
    var date: Date
    var userId: String
    
    init(amount: Double, category: String, note: String = "", date: Date = Date(), userId: String) {
        self.amount = amount
        self.category = category
        self.note = note
        self.date = date
        self.userId = userId
    }
}
