//
//  GoogleAutocompleteService.swift
//  Scigic
//
//  Created by Nidhish Gajjar on 2023-08-13.
//

import Foundation



class GoogleAutocompleteService {

    weak var delegate: GoogleAutocompleteServiceDelegate?

    // Maximum try count to get suggestions
    private let maxTries = 3
    // Initial try count
    private var tryCount = 0
    // Maximum length of askText
    private let maxLength = 75



    func fetchGoogleAutoCompleteSuggestions(_ askText: String) {
        // Check if askText length is acceptable
        guard askText.count <= maxLength else {
            return
        }

        // URL encoding
        guard let encodedAskText = askText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return
        }

        // URL for an API call
        guard let url = URL(string: "https://www.google.com/complete/search?q=\(encodedAskText)&gl=us&hl=en&client=chrome") else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            // Error handing
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            // Check if the data is not empty
            guard let unwrappedData = data else {
                print("No data received")
                return
            }

            do {
                // Decode JSON data
                if let jsonObject = try JSONSerialization.jsonObject(with: unwrappedData, options: []) as? [Any],
                   let suggestions = jsonObject[1] as? [String] {

                    // Check if there are any suggestions
                    if suggestions.count == 0 {
                        // Retry if no suggestions returned and if try count is less than maximum tries
                        if self?.tryCount ?? 0 < self?.maxTries ?? 3 {
                            self?.tryCount += 1
                        }
//                        else {
//                            print("Failed to get suggestions, stopping API calls")
//                        }
                        return
                    }
                    DispatchQueue.main.async {
                        // Update your UI with these suggestions here
                        self?.delegate?.didReceiveSuggestions(suggestions)

                        // Reset try count on successful response
                        self?.tryCount = 0
                    }
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }

        task.resume()
    }

}


protocol GoogleAutocompleteServiceDelegate: AnyObject {
    func didReceiveSuggestions(_ suggestions: [String])
}
