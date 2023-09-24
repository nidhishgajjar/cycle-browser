
//  Created by Nidhish Gajjar on 2023-06-11.
//

import SwiftUI

struct URLButton: View {
    let url: String

    @State private var showCopyLink: Bool = false
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: {
            let pasteboard = NSPasteboard.general
            pasteboard.declareTypes([.string], owner: nil)
            pasteboard.setString(url, forType: .string)
        }) {
            Group {
                if showCopyLink {
                    Text("copy link")
                } else {
                    Text(formattedUrl)
                }
            }
            .padding(.horizontal, 20) // reduced horizontal padding
            .padding(.vertical, 4) // reduced vertical padding
            .background(Color.gray.opacity(0.2)) // this will be the background color of the button
            .foregroundColor(colorScheme == .dark ? .primary.opacity(0.6) : .secondary.opacity(0.6))
            .cornerRadius(7) // this will make the corners rounded
        }
        .buttonStyle(PlainButtonStyle()) // apply a plain style to the button
        .onHover { hovering in
            showCopyLink = hovering
        }
    }
    
    var formattedUrl: String {
        guard let urlComponents = URLComponents(string: url),
              let host = urlComponents.host else {
            return url
        }
        // Remove 'www.' from the host if it exists
        return host.replacingOccurrences(of: "www.", with: "")
    }
}
