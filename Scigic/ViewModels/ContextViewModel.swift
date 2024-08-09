
//  Created by Nidhish Gajjar on 2023-06-10.
//
import Foundation
import Combine
import SwiftUI
import Markdown


struct IdentifiableParserResult: Identifiable {
    let id = UUID()
    let parserResult: ParserResult
}



class ContextViewModel: ObservableObject {
//  AskView States
    @Published var askText: String = ""
    @Published var suggestedAskText: String = ""
    @Published var askTextFromPalette = ""
    @Published var isAskViewActive: Bool = true
    @Published var askBarFocusedOnAGI: Bool = false
    @Published var currentSlateURL: URL?
    @Published var currentSlateHumanAGIRequest: String?
    @Published var hoverAutoSuggestState: Bool = false
    @Published var arrowKeyForNavSuggestions: Bool = false
    @Published var typingInAskBar: Bool = false
    


    
//  PopViewStates
    @Published var isPopVisible: Bool = false
    @Published var isJobsPopActive: Bool = false
    @Published var isNotificationsPopActive: Bool = false
    @Published var isHistoryPopActive: Bool = false
    
//  SlateView States
    @Published var currentSlate: Bool = false
    @Published var shouldMoveCurrentSlateToLast = false
    @Published var relevantAutofillInputs: Bool = false
    
    


    
//  ClipView States
    struct Clip {
        let url: URL
        var slateUUID: UUID?
    }
    
    @Published var clips = [
        Clip(url: URL(string: "https://chat.openai.com")!, slateUUID: nil),
        Clip(url: URL(string: "https://notion.so")!, slateUUID: nil),
        Clip(url: URL(string: "https://twitter.com")!,  slateUUID: nil),
        Clip(url: URL(string: "https://app.slack.com/client/T06RQBSP7TM/D06S35D0R33")!, slateUUID: nil),
        Clip(url: URL(string: "https://pinterest.com")!, slateUUID: nil),
        Clip(url: URL(string: "https://vercel.com")!, slateUUID: nil),
        Clip(url: URL(string: "https://youtube.com")!, slateUUID: nil),
        Clip(url: URL(string: "https://firebase.google.com")!, slateUUID: nil),
        Clip(url: URL(string: "https://render.com")!,  slateUUID: nil),
        Clip(url: URL(string: "https://github.com/nidhishgajjar?tab=repositories")!, slateUUID: nil),
    ]

    
//   Loading state
    @Published var isBeating = false

    
    

}
