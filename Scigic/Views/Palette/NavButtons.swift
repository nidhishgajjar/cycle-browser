
//  Created by Nidhish Gajjar on 2023-06-11.
//

import SwiftUI


struct NavButtons: View {
    let url: String
    @State private var isPassNavButtonLoading: Bool = false
    @EnvironmentObject var commonContext: ContextViewModel
    @EnvironmentObject var slateManager: SlateManagerViewModel

    var body: some View {
        HStack {
            
            
            // Left end buttons
            
            if !url.isEmpty {
                BackForwardButtons()
                if isPassNavButtonLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .scaleEffect(0.5, anchor: .center)
                        .padding(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
                } else {
                    Button(action: {
                        self.isPassNavButtonLoading = true
                        if let url = URL(string: "x-apple.systempreferences:com.apple.Passwords-Settings.extension") {
                            let configuration = NSWorkspace.OpenConfiguration()
                            NSWorkspace.shared.open(url, configuration: configuration, completionHandler: { (app, error) in
                                // Introduce a delay before hiding the loading indicator.
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    self.isPassNavButtonLoading = false
                                }
                            })
                        }
                    }) {
                        Image(systemName: "key")
                            .resizable()
                            .foregroundColor(.gray.opacity(0.7))
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15, height: 15) // Adjust size as needed
                    }
                    .keyboardShortcut(KeyEquivalent("p"), modifiers: .command)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                    .buttonStyle(PlainButtonStyle())
                }
                
                URLButton(url: url)
//                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                Button(action: {
                    slateManager.reloadCurrentSlate()
                }) {
                    // Replace text with an image
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .foregroundColor(.gray.opacity(0.7))
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 14) // Adjust size as needed
                }
    //            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 3))
                .buttonStyle(PlainButtonStyle()) // Use a plain style to avoid the default button style
            }
            
            
            
            
            
            
            Spacer()
            
            
            
            
            
            // Right end buttons
            
//            Button(action: {
//                commonContext.isPopVisible = true
//                commonContext.isJobsPopActive = true
//            }) {
//                // Replace text with an image
//                Image(systemName: "case")
//                    .resizable()
//                    .foregroundColor(.gray.opacity(0.7))
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 16, height: 16) // Adjust size as needed
//            }
//            .padding(EdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7))
//            .buttonStyle(PlainButtonStyle()) // Use a plain style to avoid the default button style

            Button(action: {
                commonContext.isAskViewActive.toggle()
            }) {
                Image(systemName: "house")
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.9))
                    .padding(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 15))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}



