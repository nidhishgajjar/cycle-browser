
//  Created by Nidhish Gajjar on 2023-06-11.
//
  
import SwiftUI
import WebKit


struct WebView: NSViewRepresentable {
    @EnvironmentObject var tabManager: TabManagerViewModel
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        tabManager.view(for: url)
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        
    }

    typealias NSViewType = WKWebView
}
