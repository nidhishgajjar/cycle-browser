//
//  AutoSuggestViewModel.swift
//  Scigic
//
//  Created by Nidhish Gajjar on 2023-08-13.
//

import Foundation
import AppKit
import Speech


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
    

    private func prepareFinalSuggestions(_ suggestions: [String]) -> [String] {

        let urlSuggestions = suggestions.filter { $0.hasPrefix("https") }.prefix(2)
        var regularSuggestions = suggestions.filter { !$0.hasPrefix("http") }.prefix(6)


        
        // Adjust according to the minimum number of regular queries
        switch urlSuggestions.count {
        case 2:
            regularSuggestions = suggestions.filter { !$0.hasPrefix("http") }.prefix(4)
        case 1:
            regularSuggestions = suggestions.filter { !$0.hasPrefix("http") }.prefix(5)
        default:
            break
        }
        

        // Combine regular queries and URL queries
        let finalSuggestions = Array(regularSuggestions.reversed() + urlSuggestions)
        

        return finalSuggestions
    }
}
