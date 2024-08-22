import Foundation
import AppKit
import WebKit

class AutoSuggestViewModel: ObservableObject, GoogleAutocompleteServiceDelegate {
    
    let googleService = GoogleAutocompleteService()
    @Published var suggestions: [SuggestionItem] = []
    var tabManager: TabManagerViewModel?
    private var currentQuery: String = ""
    
    init(tabManager: TabManagerViewModel) {
        self.googleService.delegate = self
        self.tabManager = tabManager
        print("AutoSuggestViewModel initialized with TabManager") // Debug
    }
    
    func didReceiveSuggestions(_ suggestions: [String]) {
        print("Received \(suggestions.count) suggestions from Google") // Debug
        self.prepareFinalSuggestions(suggestions, for: self.currentQuery)
    }
    
    func fetchSuggestions(for query: String) {
        print("Fetching suggestions for query: \(query)") // Debug
        self.currentQuery = query
        googleService.fetchGoogleAutoCompleteSuggestions(query)
    }

    private func prepareFinalSuggestions(_ suggestions: [String], for query: String) {
        var finalSuggestions: [SuggestionItem] = []
        
        // Handle URL and search suggestions first
        let urlSuggestions = suggestions.filter { $0.hasPrefix("https") }.prefix(2)
        let regularSuggestions = suggestions.filter { !$0.hasPrefix("http") }

        finalSuggestions.append(contentsOf: urlSuggestions.map { SuggestionItem(text: $0, type: .url) })
        finalSuggestions.append(contentsOf: regularSuggestions.map { SuggestionItem(text: $0, type: .search) })

        // Limit URL and search suggestions to 6 (leaving room for 1 tab suggestion)
        finalSuggestions = Array(finalSuggestions.prefix(6))

        // Now handle tab suggestions
        if let tabs = tabManager?.tabs {
            print("Found \(tabs.count) tabs in TabManager") // Debug
            let matchingTabs = tabs.filter { tab in
                if let url = tab.url?.absoluteString.lowercased() {
                    let query = query.lowercased()
                    return url.contains(query)
                }
                return false
            }

            print("Found \(matchingTabs.count) matching tabs") // Debug

            if let firstMatchingTab = matchingTabs.first {
                // Attempt to get the title from the web view
                let title = getTitleForTab(firstMatchingTab)
                let tabSuggestion = SuggestionItem(
                    text: title,
                    type: .tab,
                    tabUUID: firstMatchingTab.tabUUID
                )
                finalSuggestions.append(tabSuggestion)
                print("Added 1 tab suggestion: \(tabSuggestion.text)") // Debug
            }
        }

        print("Prepared \(finalSuggestions.count) final suggestions") // Debug
        
        DispatchQueue.main.async {
            self.suggestions = finalSuggestions
        }
    }
    
    private func getTitleForTab(_ tab: TabManagerViewModel.Tab) -> String {
        // This method attempts to get the title from the web view
        // You may need to adjust this based on your exact implementation
        if let webView = tab.webView as? WKWebView {
            return webView.title ?? tab.url?.host ?? "Untitled"
        }
        return tab.url?.host ?? "Untitled"
    }
}
