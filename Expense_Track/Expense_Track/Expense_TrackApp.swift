//
//  Expense_TrackApp.swift
//  Expense_Track
//
//  Created by Sid Kumar on 6/29/25.
//

import SwiftUI
import Firebase

@main
struct Expense_TrackApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
