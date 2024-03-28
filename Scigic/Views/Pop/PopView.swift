
//  Created by Nidhish Gajjar on 2023-06-11.
//
import SwiftUI


//struct PopView: View {
//    @EnvironmentObject var commonContext: ContextViewModel
//
//    var body: some View {
//            VStack {
//                if commonContext.isJobsPopActive {
//                    HStack {
//                        Text("Jobs")
//                            .font(.headline)
//                            .foregroundColor(.black.opacity(0.8))
//                            .padding()
//                        
//                        Spacer()
//
//                        Button(action: {
//                            commonContext.isPopVisible = false
//                            commonContext.isJobsPopActive = false
//                        }) {
//                            Text("Close")
//                                .foregroundColor(.black)
//                        }
//                        .padding()
//                    }
//                    // Job Details
//                    VStack {
//                        JobsPopView()
//                            .cornerRadius(10)
//                    }
//                }
//                else if commonContext.isNotificationsPopActive {
//                    HStack {
//                        Text("Notifications")
//                            .font(.headline)
//                            .padding()
//
//                        Button(action: {
//                            commonContext.isPopVisible = false
//                            commonContext.isNotificationsPopActive = false
//                        }) {
//                            Text("Close")
//                        }
//                        .padding()
//                    }
//                    // Notifications Details
//                    VStack {
//                        // ...
//                    }
//                }
//                else if commonContext.isHistoryPopActive {
//                    HStack {
//                        Text("History")
//                            .font(.headline)
//                            .padding()
//
//                        Button(action: {
//                            commonContext.isPopVisible = false
//                            commonContext.isHistoryPopActive = false
//                        }) {
//                            Text("Close")
//                        }
//                        .padding()
//                    }
//                    // History Details
//                    VStack {
//                        // ...
//                    }
//                }
//            }
//            .padding(EdgeInsets(top: 25, leading: 75, bottom: 100, trailing: 75))
//            .frame(maxWidth: .infinity)
//            .frame(maxHeight: .infinity)
//            .background(
//                VisualBlurEffect(material: .fullScreenUI) // Change the material here
//                    .overlay(
//                        Rectangle()
//                            .fill(Color(red: 241/255, green: 241/255, blue: 241/255).opacity(0.1))
//                    )
//            )
//            .cornerRadius(10)
//        }
//}
