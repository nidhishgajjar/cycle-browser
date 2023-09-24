
//
//  Created by Nidhish Gajjar on 2023-06-28.
//

import SwiftUI

struct BackForwardButtons: View {
    @EnvironmentObject var slateManager: SlateManagerViewModel
    
    var body: some View {
        if slateManager.slates.count > 0 && slateManager.currentSlateIndex < slateManager.slates.count {
            HStack {
                Button(action: {
                    slateManager.goBack()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16))
                }
                .disabled(!(slateManager.slates[slateManager.currentSlateIndex].webView?.canGoBack ?? false))
                .opacity(slateManager.slates[slateManager.currentSlateIndex].webView?.canGoBack ?? false ? 1 : 0.3) // Add this line
                .buttonStyle(PlainButtonStyle())
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 7))

                Button(action: {
                    slateManager.goForward()
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16))
                }
                .disabled(!(slateManager.slates[slateManager.currentSlateIndex].webView?.canGoForward ?? false))
                .opacity(slateManager.slates[slateManager.currentSlateIndex].webView?.canGoForward ?? false ? 1 : 0.3) // And this line
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

