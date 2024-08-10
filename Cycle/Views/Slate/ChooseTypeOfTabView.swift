
//  Created by Nidhish Gajjar on 2023-06-11.
//

import SwiftUI

struct ChooseTypeOfTabView: View {
    @Binding var tab: TabManagerViewModel.Tab
    @EnvironmentObject var tabManager: TabManagerViewModel
    @EnvironmentObject var commonContext: ContextViewModel
    @FocusState private var webviewFocused: Bool // Add @FocusState property

    var body: some View {
        if tab.isThinking {
            // Need to keep tabUUID here as we will need it in the error view to close tab
            ThinkingView(errorCopyText: tab.currentUrl?.absoluteString ?? "Please try to disable and re-enable the app", tab.tabUUID)
        } else if let webViewUrl = tab.url {
            WebView(url: webViewUrl)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedCornersShape(topLeft: 10, topRight: 10, bottomLeft: 0, bottomRight: 0))
                .focused($webviewFocused)
                .onAppear {
                    DispatchQueue.main.async {
                        webviewFocused = true
                    }
                }
        }
    }
}
