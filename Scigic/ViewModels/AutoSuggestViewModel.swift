//
//  AutoSuggestViewModel.swift
//  Scigic
//
//  Created by Nidhish Gajjar on 2023-08-13.
//

import Foundation
import AppKit


class AutoSuggestViewModel: ObservableObject, GoogleAutocompleteServiceDelegate {
    
    let googleService = GoogleAutocompleteService()
    
    @Published var suggestions: [String] = []
    
    init() {
        self.googleService.delegate = self
    }
    
    
    func didReceiveSuggestions(_ suggestions: [String]) {
        self.suggestions = prepareFinalSuggestions(suggestions)
        
    }
    
    func fetchSuggestions(for query: String) {
        googleService.fetchGoogleAutoCompleteSuggestions(query)
    }
    
    private func isValidURL(_ string: String) -> Bool {
        // The URL initializer checks if the string can be converted to a URL.
        // If it can, the initializer will return a non-nil URL object.
        // Therefore, we can use this to determine if the string is a valid URL.
        return URL(string: string) != nil
    }

    private func prepareFinalSuggestions(_ suggestions: [String]) -> [String] {
        let urlSuggestions = suggestions.filter { $0.hasPrefix("https") && isValidURL($0) }.prefix(2)
        var regularSuggestions = suggestions.filter { !$0.hasPrefix("http") && !isValidURL($0) }.prefix(6)

        // Adjust according to the minimum number of regular queries
        switch urlSuggestions.count {
        case 2:
            regularSuggestions = suggestions.filter { !$0.hasPrefix("http") && !isValidURL($0) }.prefix(4)
        case 1:
            regularSuggestions = suggestions.filter { !$0.hasPrefix("http") && !isValidURL($0) }.prefix(5)
        default:
            break
        }

        // Combine regular queries and URL queries
        let finalSuggestions = Array(regularSuggestions.reversed() + urlSuggestions)

        return finalSuggestions
    }
}
