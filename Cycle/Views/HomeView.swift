//
//  SwitchView.swift
//  scigic
//
//  Created by Nidhish Gajjar on 2023-07-18.
//

import SwiftUI


struct HomeView: View {
//    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var commonContext: ContextViewModel

    var body: some View {
        ZStack {
            // Always show the TabView
            BrowserTabView()
            

            // Conditionally show the AskView
            if commonContext.isAskViewActive {
                AskView()
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 39))
            }
        }
//        .onReceive(authManager.$isEmailVerified) { isVerified in
//            if isVerified {
//                authManager.stopEmailVerificationTimer()
//            }
//        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("mouseClickedOutside")), perform: { _ in
            self.commonContext.isAskViewActive = false
            self.commonContext.askTextFromPalette = ""
            self.commonContext.askBarFocusedOnAGI.toggle()
            self.commonContext.isPopVisible = false
        })
    }
}
