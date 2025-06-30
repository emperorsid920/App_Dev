//
//  ContentView.swift
//  Expense_Track
//
//  Created by Sid Kumar on 6/29/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    var body: some View {
        Group {
            if firebaseManager.isAuthenticated {
                // Show main app when user is logged in
                DashboardView()
            } else {
                // Show login when user is not logged in
                LoginView()
            }
        }
        .animation(.easeInOut, value: firebaseManager.isAuthenticated)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
