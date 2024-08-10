
//
//  Created by Nidhish Gajjar on 2023-06-28.
//

import SwiftUI

struct BackForwardButtons: View {
    @EnvironmentObject var tabManager: TabManagerViewModel
    
    var body: some View {
        if tabManager.tabs.count > 0 && tabManager.currentTabIndex < tabManager.tabs.count {
            HStack {
                Button(action: {
                    tabManager.goBack()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16))
                }
                .disabled(!(tabManager.tabs[tabManager.currentTabIndex].webView?.canGoBack ?? false))
                .opacity(tabManager.tabs[tabManager.currentTabIndex].webView?.canGoBack ?? false ? 1 : 0.3) // Add this line
                .buttonStyle(PlainButtonStyle())
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 7))

                Button(action: {
                    tabManager.goForward()
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16))
                }
                .disabled(!(tabManager.tabs[tabManager.currentTabIndex].webView?.canGoForward ?? false))
                .opacity(tabManager.tabs[tabManager.currentTabIndex].webView?.canGoForward ?? false ? 1 : 0.3) // And this line
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

