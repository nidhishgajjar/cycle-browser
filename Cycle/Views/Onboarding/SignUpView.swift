
//  Created by Nidhish Gajjar on 2023-06-08.
//

//import SwiftUI
//
//struct SignUpView: View {
//    @EnvironmentObject var authManager: AuthManager
//    @State private var email = ""
//    @State private var password = ""
//    var body: some View {
//        VStack {
//            Text("Sign Up").font(.largeTitle).bold().padding()
//            TextField("Email", text: $email)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//            SecureField("Password", text: $password)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//            Button("Sign Up") {
//                authManager.signUpUser(email: email, password: password)
//            }
//            .padding()
////            NavigationLink("Already have an account? Log In", destination: LoginView())
//        }
////        .padding()
////        .modifier(CanvasStyling())
//    }
//}
//
//struct SignUpView_Provider: PreviewProvider {
//    static var previews: some View {
//        SignUpView()
//    }
//}
