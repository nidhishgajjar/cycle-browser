
//  Created by Nidhish Gajjar on 2023-06-10.
//
import Foundation
import Combine
import SwiftUI


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
        Clip(url: URL(string: "https://chatgpt.com")!, tabUUID: nil),
        Clip(url: URL(string: "https://www.notion.so/d28964c01d1e44c3a9db08e1ade47f04")!, tabUUID: nil),
        Clip(url: URL(string: "https://x.com")!,  tabUUID: nil),
        Clip(url: URL(string: "https://nextui.org/docs/components/avatar")!, tabUUID: nil),
        Clip(url: URL(string: "https://vercel.com/nidhishgajjars-projects")!, tabUUID: nil),
        Clip(url: URL(string: "https://claude.ai")!, tabUUID: nil),
        Clip(url: URL(string: "https://www.youtube.com/")!, tabUUID: nil),
        Clip(url: URL(string: "https://supabase.com/dashboard/project/uapllucryvzxrgctfqyf")!, tabUUID: nil),
        Clip(url: URL(string: "https://dashboard.render.com/")!,  tabUUID: nil),
        Clip(url: URL(string: "https://github.com/nidhishgajjar?tab=repositories")!, tabUUID: nil),
    ]

    
//   Loading state
    @Published var isBeating = false

    
    

}
