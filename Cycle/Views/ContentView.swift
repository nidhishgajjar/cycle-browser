//
//  ContentView.swift
//  scigic
//
//  Created by Nidhish Gajjar on 2023-07-18.
//

import SwiftUI

struct ContentView: View {
//    @EnvironmentObject var webSocketService: WebSocketService

    var body: some View {
        Group {
//            if authManager.isUserLoggedIn && webSocketService.hasActiveSubscription {
                HomeView()
//            }
//            else {
//                LoginView()
//            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(20)
    }
}

