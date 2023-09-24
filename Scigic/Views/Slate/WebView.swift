
//  Created by Nidhish Gajjar on 2023-06-11.
//

import SwiftUI
import WebKit


struct WebView: NSViewRepresentable {
    @EnvironmentObject var slateManager: SlateManagerViewModel
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        slateManager.view(for: url)
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        
        // check if humanAGIRequest is nil then it doesn't have a url so nothing needs to be updated
//        if nsView.url != url && slateManager.slates[slateManager.currentSlateIndex].humanAGIRequest == nil {
//            nsView.load(URLRequest(url: url))
//        }
    }

    typealias NSViewType = WKWebView
}
