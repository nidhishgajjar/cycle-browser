
//  Created by Nidhish Gajjar on 2023-06-11.
//

import SwiftUI

struct ChooseTypeOfSlateView: View {
    @Binding var slate: SlateManagerViewModel.Slate
    @EnvironmentObject var slateManager: SlateManagerViewModel
    @EnvironmentObject var commonContext: ContextViewModel
    @FocusState private var webviewFocused: Bool // Add @FocusState property

    var body: some View {
        if slate.isThinking {
            // Need to keep slateUUID here as we will need it in the error view to close slate
            ThinkingView(errorCopyText: slate.humanAGIRequest ?? slate.currentUrl?.absoluteString ?? "Please try to disable and re-enable the app", slateUUID: slate.slateUUID)
        } else if let webViewUrl = slate.url {
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
        else if let humanAGIRequest = slate.humanAGIRequest, let interface = commonContext.interfaces[slate.slateUUID] {
            AGIView(interface: interface, humanAGIRequest: humanAGIRequest)
                .onAppear {
//                    print("AGI Slate appeared")
//                    print(slateManager.currentSlateIndex)
                    DispatchQueue.main.async {
                        commonContext.askBarFocusedOnAGI = true
                    }
                }
        }
    }
}
