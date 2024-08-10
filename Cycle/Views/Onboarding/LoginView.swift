
//  Created by Nidhish Gajjar on 2023-06-08.
//
//
//import SwiftUI
//
//struct LoginView: View {
//    @EnvironmentObject var authManager: AuthManager
//    @State private var email = ""
//    @State private var password = ""
//    @State private var errorMessage: LoginError?
//
//    var body: some View {
//        if authManager.isAuthLoading {
//            ThinkingView(errorCopyText: "Login failure 5673", slateUUID: UUID())
//        } else {
//            ZStack {
//                VisualBlurEffect(material: .sidebar)
//                    .overlay(
//                        RoundedCornersShape(topLeft: 10, topRight: 10, bottomLeft: 0, bottomRight: 0).fill(
//                                Color(red: 62/255, green: 62/255, blue: 62/255).opacity(0.3)
//                        )
//                    )
//
//                VStack {
//                    VStack {
//                        Text("Login").font(.largeTitle).bold().padding()
//                        Text("(Use the credentials you used for Chad)")
//                    }
//
//                    TextField("Email", text: $email)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .padding()
//
//                    SecureField("Password", text: $password, onCommit: {
//                        attemptLogin()
//                    })
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .padding()
//
//                    Button("Login") {
//                        attemptLogin()
//                    }
//                }
//                .padding(.horizontal, 50)
//                .frame(maxWidth: 500)
//                .alert(item: $errorMessage) { error in
//                    Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
//                }
//            }
//        }
//    }
//
//    func attemptLogin() {
//        authManager.loginUser(email: email, password: password) { error in
//            if let error = error {
//                errorMessage = LoginError(message: error)
//            }
//        }
//    }
//}
//
//struct LoginError: Identifiable {
//    let id = UUID()
//    let message: String
//}
