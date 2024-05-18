
//  Created by Nidhish Gajjar on 2023-07-04.
//

import SwiftUI

//struct AGIHumanApprovalView: View {
//    @EnvironmentObject var slateManager: SlateManagerViewModel
//    @EnvironmentObject var commonContext: ContextViewModel
//
//    var body: some View {
//        Text("AGI Human Approval")
//    }
//}


//struct AGIHumanApprovalView: View {
//    @EnvironmentObject var commonContext: ContextViewModel
//    @EnvironmentObject var slateManager: SlateManagerViewModel
////    @EnvironmentObject var webSocketService: WebSocketService
//    
//    @State private var approvalID: String = ""
//    @State private var recipientEmail: String = ""
//    @State private var emailSubject: String = ""
//    @State private var emailBody: String = ""
//    @State private var isLoading: Bool = false
//
//    let slateUUID: UUID
//
//    var body: some View {
//        ZStack {
//            if isLoading { // Loading view when send button is pressed
//                Color.black.opacity(0.4)
//                    .ignoresSafeArea() // This will cover the entire screen with a semi-transparent layer when loading
//                
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
//                    .scaleEffect(2, anchor: .center)
//            } else {
//                
//                RoundedCornersShape(topLeft: 10, topRight: 10, bottomLeft: 0, bottomRight: 0)
//                    .fill(Color(red: 249/255, green: 249/255, blue: 249/255))
//                
//                VStack (alignment: .leading) {
//                    
//                    Text("Hey, here is your draft let me know if you'd like me to send it?")
//                        .font(.system(size: 16))
//                        .fontWeight(.light)
//                        .lineSpacing(5)
//                        .kerning(0.75)
//                        .padding(EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20))
//                        .foregroundColor(Color.black.opacity(0.75))
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(10)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(EdgeInsets(top: 30, leading: 20, bottom: 20, trailing: 0))
//                    
//                    HStack() {
//                        Text("To:")
//                            .font(.system(size:11))
//                            .foregroundColor(Color.gray)
//                        
//                        TextField("Enter recipient email", text: $recipientEmail)
//                            .textFieldStyle(PlainTextFieldStyle())
//                            .foregroundColor(.gray)
//                            .font(.system(size: 13))
//                            .fontWeight(.light)
//                            .kerning(0.75)
//                    }
//                    .padding(.vertical, 10)
//                    .padding(.horizontal, 22)
//                    
//                    HStack() {
//                        Text("Subject:")
//                            .font(.system(size:11))
//                            .foregroundColor(Color.gray)
//                        TextField("Enter email subject", text: $emailSubject)
//                            .textFieldStyle(PlainTextFieldStyle())
//                            .foregroundColor(.gray)
//                            .font(.system(size: 14))
//                            .kerning(0.75)
//                    }
//                    .padding(.vertical, 10)
//                    .padding(.horizontal, 22)
//                    
//                    ZStack {
//                        RoundedCornersShape(topLeft: 10, topRight: 10, bottomLeft: 10, bottomRight: 10)
//                            .fill(.white)
//                        TextEditor(text: $emailBody)
//                            .scrollContentBackground(.hidden)
//                            .padding(20)
//                            .cornerRadius(15)
//                            .font(.system(size: 15))
//                            .fontWeight(.light)
//                            .lineSpacing(5)
//                            .kerning(0.75)
//                            .foregroundColor(Color.black.opacity(0.8))
//                    }
//                    .padding(.top, 20)
//                    .padding(.horizontal, 22)
//                    
//                    HStack {
//                        Spacer()
//                        Button(action: {
//                            // Code to cancel
////                            print("Email canceled")
//                        }) {
//                            Image(systemName: "xmark.circle.fill") // Use a system-provided icon
//                                .font(.system(size: 20)) // Increase the size of the icon
//                                .foregroundColor(Color.red) // Make the icon red
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 15))
//                        
//                        Button(action: {
//                            isLoading = true
////                            if !webSocketService.isConnected {
////                                webSocketService.connect()
////                            }
//                            // Prepare the mindRequest content.
//                            let mindRequest: [String: Any] = [
//                                "approvalID": approvalID,
//                                "status": "approved",
//                                "inputParams": ["recipient_email_id": recipientEmail,"subject": emailSubject, "body": emailBody]
//                            ]
//                            
//                            // Send the message.
//                            webSocketService.send(slateUUID: slateUUID.uuidString, mindRequest: mindRequest, reqType: "human-approval")
//                        }) {
//                            Text("Send it")
//                                .font(.system(size: 15))
//                                .foregroundColor(Color.white)
//                                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
//                                .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.black]), startPoint: .bottomLeading, endPoint: .topTrailing))
//                        }
//                        .cornerRadius(10)
//                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 30))
//                }
//                .onAppear {
//                    if let approval = commonContext.approval.first(where: {$0.slateUUID == slateUUID}) {
//                        approvalID = approval.approvalID
//                        recipientEmail = approval.inputParams["recipient_email_id"] as? String ?? ""
//                        emailSubject = approval.inputParams["subject"] as? String ?? ""
//                        emailBody = approval.inputParams["body"] as? String ?? ""
//                    }
//                }
//                .padding(EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 20))
//            }
//        }
//    }
//}



//struct AGIHumanApprovalView_Previews: PreviewProvider {
//    static var previews: some View {
//        AGIHumanApprovalView()
//    }
//}

//
//{
//    "toolID": "emailEditor",
//    "toolAction": "composeEmail",
//    "interfaceComponents": [
//        {
//            "type": "title",
//            "text": "Email Approval",
//            "color": "#000000",
//            "fontSize": 24,
//            "padding": [10, 0, 0, 0]
//        },
//        {
//            "type": "label",
//            "text": "Recipient Email",
//            "color": "#000000",
//            "fontSize": 18,
//            "padding": [10, 0, 0, 0]
//        },
//        {
//            "type": "textField",
//            "binding": "recipientEmail",
//            "color": "#000000",
//            "fontSize": 18,
//            "padding": [10, 0, 0, 0]
//        },
//        {
//            "type": "button",
//            "text": "Approve",
//            "action": "approve",
//            "color": "#FFFFFF",
//            "backgroundColor": "#006400",
//            "fontSize": 18,
//            "padding": [10, 0, 0, 0]
//        },
//        {
//            "type": "button",
//            "text": "Decline",
//            "action": "decline",
//            "color": "#FFFFFF",
//            "backgroundColor": "#8B0000",
//            "fontSize": 18,
//            "padding": [10, 0, 0, 0]
//        }
//    ]
//}
//

//struct DynamicComponent: View {
//    var component: Component // Component is a model struct for the JSON data
//
//    var body: some View {
//        switch component.type {
//        case "title":
//            Text(component.text)
//                .font(.system(size: CGFloat(component.fontSize)))
//                .foregroundColor(Color(hex: component.color))
//                .padding(EdgeInsets(
//                    top: CGFloat(component.padding[0]),
//                    leading: CGFloat(component.padding[1]),
//                    bottom: CGFloat(component.padding[2]),
//                    trailing: CGFloat(component.padding[3])
//                ))
//        case "label":
//            // Similar code for label...
//        case "textField":
//            TextField("", text: $component.binding)
//                .font(.system(size: CGFloat(component.fontSize)))
//                .foregroundColor(Color(hex: component.color))
//                .padding(EdgeInsets(
//                    top: CGFloat(component.padding[0]),
//                    leading: CGFloat(component.padding[1]),
//                    bottom: CGFloat(component.padding[2]),
//                    trailing: CGFloat(component.padding[3])
//                ))
//        case "button":
//            Button(action: {
//                // Call your function here based on the action property
//            }) {
//                Text(component.text)
//                    .font(.system(size: CGFloat(component.fontSize)))
//                    .foregroundColor(Color(hex: component.color))
//                    .padding(EdgeInsets(
//                        top: CGFloat(component.padding[0]),
//                        leading: CGFloat(component.padding[1]),
//                        bottom: CGFloat(component.padding[2]),
//                        trailing: CGFloat(component.padding[3])
//                    ))
//                    .background(Color(hex: component.backgroundColor))
//            }
//        default:
//            EmptyView()
//        }
//    }
//}
//
//struct DynamicInterface: View {
//    var components: [Component]
//
//    var body: some View {
//        ForEach(components) { component in
//            DynamicComponent(component: component)
//        }
//    }
//}
