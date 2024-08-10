//
//  AskScigicButton.swift
//  Scigic
//
//  Created by Nidhish Gajjar on 2023-08-19.
//

import SwiftUI


struct AskScigicButton: View {
    let url: String
    
    @State private var showQuery: Bool = false
    @EnvironmentObject var slateManager: SlateManagerViewModel
    
    // Check if the URL is a valid Google search URL
    var isValidGoogleURL: Bool {
        return url.contains("https://www.google.com/search?q=")
    }
    
    // Extracts the search query from the given URL
    var extractedQuery: String {
        if let urlComponents = URLComponents(string: url),
           let queryItems = urlComponents.queryItems,
           let queryItem = queryItems.first(where: { $0.name == "q" }) {
            return queryItem.value ?? ""
        }
        return "Unknown Query"
    }
    
    var body: some View {
        Button(action: {
            slateManager.closeCurrentSlate()
            slateManager.addPerlexitySlate(query: extractedQuery)
        }) {
            HStack {
                Group {
                    if showQuery {
                        Text(extractedQuery)
                            .truncationMode(.tail)
                            .lineLimit(1)
                            .padding(.leading, 8)
                    } else {
                        Text("Ask Perplexity")
                    }
                }
            }
        }
        .padding(.vertical, 5)
        .frame(width: 150) // Fixed width for the button
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            showQuery = hovering
        }
    }
}
