//
//  AutoSuggestView.swift
//  Scigic
//
//  Created by Nidhish Gajjar on 2023-08-14.
//


import SwiftUI
import Combine



struct AutoSuggestView: View {
    @EnvironmentObject var slateManager: SlateManagerViewModel
    @EnvironmentObject var commonContext: ContextViewModel
    @ObservedObject var autoComplete = AutoSuggestViewModel()
    @State private var selectedIndex: Int = 5
    @State private var textHeight: CGFloat = 38
    
    @Environment(\.colorScheme) var colorScheme
    
    
    
    var body: some View {
        
        GeometryReader { geometry in
            VStack {
                Spacer()
                   ScrollView {
                       VStack(spacing: 0) {
                           ForEach(autoComplete.suggestions.indices, id: \.self) { index in
                               SuggestionItemView(suggestion: autoComplete.suggestions[index], isSelected: selectedIndex == index, index: index, action: {
                                   performAction(for: index)
                               }, selectedIndex: $selectedIndex, typingInAskBar: $commonContext.typingInAskBar, isHovered: $commonContext.hoverAutoSuggestState, isArrowKeyUsed: $commonContext.arrowKeyForNavSuggestions)
                           }
                       }
                       .frame(maxWidth: .infinity)
                   }
                   .frame(height: CGFloat(autoComplete.suggestions.count) * textHeight)
                   .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(colorScheme == .dark ? Color.clear : Color.white))

               }
            }
        .onChange(of: autoComplete.suggestions) { _ in
            selectedIndex = autoComplete.suggestions.count - 1
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willUpdateNotification)) { _ in
            if let event = NSApp.currentEvent, event.type == .keyDown {
                handleKeyDown(event: event)
            }
        }
    }
    
    func handleKeyDown(event: NSEvent) {
//        commonContext.hoverAutoSuggestState = false
//        commonContext.arrowKeyForNavSuggestions = true
//        print("Arrow key used")
//        print(commonContext.arrowKeyForNavSuggestions)
//        print("hover State")
//        print(commonContext.hoverAutoSuggestState)
        if commonContext.typingInAskBar {
            switch event.keyCode {
            case 126: // Up arrow
                commonContext.typingInAskBar = false
                commonContext.hoverAutoSuggestState = false
                commonContext.arrowKeyForNavSuggestions = true
//                print("invoked to set false")
            case 125: // Down arrow
                commonContext.typingInAskBar = false
                commonContext.hoverAutoSuggestState = false
                commonContext.arrowKeyForNavSuggestions = true
//                print("invoked to set false")
            default:
                break
            }
        } else {
            switch event.keyCode {
            case 125: // Down arrow
                commonContext.hoverAutoSuggestState = false
                commonContext.arrowKeyForNavSuggestions = true
                if selectedIndex == autoComplete.suggestions.count - 1 {
                    commonContext.typingInAskBar = true
                    commonContext.arrowKeyForNavSuggestions = false
                } else if selectedIndex < autoComplete.suggestions.count - 1 {
                    selectedIndex += 1
                }
            case 126: // Up arrow
                commonContext.hoverAutoSuggestState = false
                commonContext.arrowKeyForNavSuggestions = true
                if selectedIndex > 0 {
                    selectedIndex -= 1
                }
            case 36: // Enter key
                commonContext.arrowKeyForNavSuggestions = false
                performAction(for: selectedIndex)
                commonContext.hoverAutoSuggestState = false
            case 124: // Right arrow
                if selectedIndex >= 0 && selectedIndex < autoComplete.suggestions.count && !commonContext.typingInAskBar {
                    commonContext.typingInAskBar = true
                    commonContext.arrowKeyForNavSuggestions = false
                    commonContext.askText = autoComplete.suggestions[selectedIndex]
                    commonContext.suggestedAskText = ""
                }
            case 123: // Left arrow
                commonContext.typingInAskBar = true
                commonContext.arrowKeyForNavSuggestions = false

            default:
                break
            }
        }
    }
        
        
    func performAction(for index: Int) {
        let suggestion = autoComplete.suggestions[index]
        
        if isURLFormat(suggestion), let url = URL(string: suggestion) {
            slateManager.addNewSlate(url: url)
        } else {
            slateManager.addPerlexitySlate(query: suggestion)
        }
        
        commonContext.askBarFocusedOnAGI.toggle()
        commonContext.askText = ""
        commonContext.askTextFromPalette = ""
    }

    func isURLFormat(_ suggestion: String) -> Bool {
        return suggestion.starts(with: "http://") || suggestion.starts(with: "https://")
    }


}






//                    commonContext.suggestedAskText = autoComplete.suggestions[selectedIndex]
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//                        commonContext.arrowKeyForNavSuggestions = true
//                            commonContext.typingInAskBar = false
//                            print("Invoked to set false after 0.1 second")
//                        }
