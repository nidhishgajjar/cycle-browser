
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
    @Published var currentTabURL: URL?
    @Published var hoverAutoSuggestState: Bool = false
    @Published var arrowKeyForNavSuggestions: Bool = false
    @Published var typingInAskBar: Bool = false
    


    
//  PopViewStates
    @Published var isPopVisible: Bool = false
    @Published var isJobsPopActive: Bool = false
    @Published var isNotificationsPopActive: Bool = false
    @Published var isHistoryPopActive: Bool = false
    
//  TabView States
    @Published var currentTab: Bool = false
    @Published var shouldMoveCurrentTabToLast = false
    @Published var relevantAutofillInputs: Bool = false
    
    


    
//  ClipView States
    struct Clip {
        let url: URL
        var tabUUID: UUID?
    }
    
    @Published var clips = [
        Clip(url: URL(string: "https://chat.openai.com")!, tabUUID: nil),
        Clip(url: URL(string: "https://notion.so")!, tabUUID: nil),
        Clip(url: URL(string: "https://twitter.com")!,  tabUUID: nil),
        Clip(url: URL(string: "https://app.slack.com/client/T06RQBSP7TM/D06S35D0R33")!, tabUUID: nil),
        Clip(url: URL(string: "https://pinterest.com")!, tabUUID: nil),
        Clip(url: URL(string: "https://vercel.com")!, tabUUID: nil),
        Clip(url: URL(string: "https://youtube.com")!, tabUUID: nil),
        Clip(url: URL(string: "https://firebase.google.com")!, tabUUID: nil),
        Clip(url: URL(string: "https://render.com")!,  tabUUID: nil),
        Clip(url: URL(string: "https://github.com/nidhishgajjar?tab=repositories")!, tabUUID: nil),
    ]

    
//   Loading state
    @Published var isBeating = false

    
    

}
