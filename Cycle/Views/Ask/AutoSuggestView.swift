import SwiftUI
import Combine

import Foundation

public enum SuggestionType: Equatable {
    case search
    case url
    case tab
}

public struct SuggestionItem: Identifiable, Equatable {
    public let id = UUID()
    public let text: String
    public let type: SuggestionType
    public let tabUUID: UUID?
    
    public init(text: String, type: SuggestionType, tabUUID: UUID? = nil) {
        self.text = text
        self.type = type
        self.tabUUID = tabUUID
    }
    
    public static func == (lhs: SuggestionItem, rhs: SuggestionItem) -> Bool {
        return lhs.id == rhs.id && lhs.text == rhs.text && lhs.type == rhs.type && lhs.tabUUID == rhs.tabUUID
    }
}


struct AutoSuggestView: View {
    @EnvironmentObject var tabManager: TabManagerViewModel
    @EnvironmentObject var commonContext: ContextViewModel
    @ObservedObject var autoComplete: AutoSuggestViewModel
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
                            HStack {
                                SuggestionItemView(suggestion: autoComplete.suggestions[index],
                                                   isSelected: selectedIndex == index,
                                                   index: index,
                                                   action: {
                                                       performAction(for: index)
                                                   },
                                                   selectedIndex: $selectedIndex,
                                                   typingInAskBar: $commonContext.typingInAskBar,
                                                   isHovered: $commonContext.hoverAutoSuggestState,
                                                   isArrowKeyUsed: $commonContext.arrowKeyForNavSuggestions)
                            }
                        }
                    }
                    .frame(minWidth: geometry.size.width)
                }
                .frame(height: CGFloat(autoComplete.suggestions.count) * textHeight * 1.23)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(colorScheme == .dark ? Color.black.opacity(0.1) : Color.white))
            }
            Spacer()
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
        if commonContext.typingInAskBar {
            switch event.keyCode {
            case 126, 125: // Up or Down arrow
                commonContext.typingInAskBar = false
                commonContext.hoverAutoSuggestState = false
                commonContext.arrowKeyForNavSuggestions = true
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
                    commonContext.askText = autoComplete.suggestions[selectedIndex].text
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
        guard index >= 0 && index < autoComplete.suggestions.count else { return }
        
        let suggestion = autoComplete.suggestions[index]
        
        switch suggestion.type {
        case .tab:
            if let tabUUID = suggestion.tabUUID {
                tabManager.jumpToTab(with: tabUUID)
            }
        case .url:
            if let url = URL(string: suggestion.text) {
                tabManager.addNewTab(url: url)
            }
        case .search:
            tabManager.addPerlexityTab(query: suggestion.text)
        }
        
        commonContext.askBarFocusedOnAGI.toggle()
        commonContext.askText = ""
        commonContext.askTextFromPalette = ""
    }
}
