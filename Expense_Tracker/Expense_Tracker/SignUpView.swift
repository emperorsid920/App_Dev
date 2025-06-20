
import SwiftUI

struct SignUpView: View {
    // Add new state variables for first and last name
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccess = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Sign Up")
                .font(.largeTitle)
                .bold()
            
            // Group the name fields together
            Group {
                TextField("First Name", text: $firstName)
                    .autocapitalization(.words)
                    .textContentType(.givenName)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                TextField("Last Name", text: $lastName)
                    .autocapitalization(.words)
                    .textContentType(.familyName)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                TextField("Username", text: $username)
                    .autocapitalization(.none)
                    .textContentType(.username)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
            }
            
            // Group the password fields together
            Group {
                SecureField("Password", text: $password)
                    .textContentType(.newPassword)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textContentType(.newPassword)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
            }
            
            if isLoading {
                ProgressView()
            }
            
            Button("Create Account") {
                errorMessage = nil
                // Validate all the fields
                guard !firstName.isEmpty, !lastName.isEmpty, !username.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
                    errorMessage = "All fields are required"
                    return
                }
                guard password == confirmPassword else {
                    errorMessage = "Passwords do not match"
                    return
                }
                isLoading = true
                AuthAPI.shared.signUp(
                    username: username,
                    email: email,
                    password: password,
                    password_confirm: confirmPassword,
                    first_name: firstName,
                    last_name: lastName
                ) { result in
                    DispatchQueue.main.async {
                        isLoading = false
                        switch result {
                        case .success():
                            showSuccess = true
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Spacer()
        }
        .padding()
        .alert(isPresented: $showSuccess) {
            Alert(
                title: Text("Success"),
                message: Text("Account created. Please log in."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
