
//  Created by Nidhish Gajjar on 2023-06-08.
//
//
//import FirebaseAuth
//import Combine
//
//class AuthManager: ObservableObject {
//    @Published var isUserLoggedIn: Bool = false
//    @Published var isEmailVerified: Bool = false
//    @Published var isUserSignedUp: Bool = false
//    @Published var currentUserUID: String? = nil
//    @Published var isAuthLoading: Bool = false
//
//    
//    private var cancellables = Set<AnyCancellable>()
//    private var emailVerificationTimer: Timer?
//
//    init() {
//        checkLoginStatus()
//        startEmailVerificationTimer()
//    }
//    
//    func checkLoginStatus() {
//        Auth.auth().addStateDidChangeListener { auth, user in
//            if let user = user {
//                // Verify that the user has verified their email address before logging in
//                if user.isEmailVerified {
//                    print("User is signed in")
//                    self.currentUserUID = user.uid
//                    self.isUserLoggedIn = true
//                } else {
//                    print("User has not verified their email address")
//                    self.isUserLoggedIn = false
//                }
//            } else {
//                print("User is not signed in")
//                    self.currentUserUID = nil
//                self.isUserLoggedIn = false
//            }
//        }
//    }
// 
////    func loginUser(email: String, password: String) {
////        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
////            if let error = error {
////                print("Error signing in: \(error)")
////                return
////            }
////            self?.currentUserUID = authResult?.user.uid
////            self?.isUserSignedUp = false
////            self?.checkLoginStatus()
////        }
////    }
//    
//    
//    func loginUser(email: String, password: String, completion: @escaping (String?) -> Void) {
//        self.isAuthLoading = true
//        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
//            self?.isAuthLoading = false
//            if let nsError = error as NSError? {
//                if nsError.domain == "FIRAuthErrorDomain" {
//                    switch nsError.code {
//                    case 17011:  // User not found
//                        completion("No account found with this email address.")
//                    case 17009:  // Wrong password
//                        completion("Incorrect password. Please try again.")
//                    case 17010:  // Too many requests
//                        completion("Too many login attempts. Please try again later.")
//                    // Add more cases based on Firebase's error codes as needed...
//                    default:
//                        completion("An error occurred. Please try again.")
//                    }
//                    return
//                }
//            }
//            self?.currentUserUID = authResult?.user.uid
//            self?.isUserSignedUp = false
//            self?.checkLoginStatus()
//            completion(nil) // No error
//        }
//    }
//
//
//
//    func signUpUser(email: String, password: String) {
//        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
//            if let error = error {
//                print("Error signing up: \(error)")
//                return
//            }
//            
//            authResult?.user.sendEmailVerification(completion: { error in
//                if let error = error {
//                    print("Error sending verification email: \(error)")
//                } else {
//                    print("Verification email sent")
//                    self.isUserSignedUp = true
//                }
//            })
//            self.currentUserUID = authResult?.user.uid
//            self.checkLoginStatus()
//        }
//    }
//    
//    func startEmailVerificationTimer() {
//        emailVerificationTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
//            self?.checkEmailVerificationStatus()
//        }
//    }
//    
//    func checkEmailVerificationStatus() {
//        guard let user = Auth.auth().currentUser else { return }
//
//        user.reload { [weak self] error in
//            if let error = error {
//                print("Error reloading user: \(error)")
//                return
//            }
//
//            DispatchQueue.main.async {
//                self?.isEmailVerified = user.isEmailVerified
//            }
//        }
//    }
//
//    func stopEmailVerificationTimer() {
//        emailVerificationTimer?.invalidate()
//        emailVerificationTimer = nil
//    }
//    
//    func logoutUser() {
//        do {
//            try Auth.auth().signOut()
//            self.currentUserUID = nil
//        } catch let signOutError as NSError {
//            print("Error signing out: \(signOutError)")
//        }
//        self.checkLoginStatus()
//    }
//
//    func resetPassword(completion: @escaping (Bool) -> Void) {
//          if let user = Auth.auth().currentUser {
//              let email = user.email ?? ""
//              
//              Auth.auth().sendPasswordReset(withEmail: email) { error in
//                  if let error = error {
//                      print("Error sending password reset email: \(error)")
//                      completion(false)
//                  } else {
//                      print("Password reset email sent")
//                      completion(true)
//                  }
//              }
//          } else {
//              print("No logged-in user found")
//              completion(false)
//          }
//      }
//
//
//}
//
