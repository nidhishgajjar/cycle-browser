import SwiftUI

struct SuggestionItemView: View {
    let suggestion: SuggestionItem
    let isSelected: Bool
    let index: Int
    let action: () -> Void
    @Binding var selectedIndex: Int
    @Binding var typingInAskBar: Bool
    @Binding var isHovered: Bool
    @Binding var isArrowKeyUsed: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            print("Suggestion item tapped: \(suggestion.text)") // Debug
            action()
        }) {
            VStack(alignment: .leading) {
                HStack(spacing: 10) {
                    Image(systemName: iconForSuggestionType(suggestion.type))
                        .foregroundColor(.gray)

                    Text(displayTextForSuggestion(suggestion))
                        .lineSpacing(5)
                        .kerning(0.75)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 5)
                        .foregroundColor(colorScheme == .dark ? Color.secondary : Color.primary)
                }
            }
            .padding(EdgeInsets(top: 7, leading: 10, bottom: 7, trailing: 0))
            .foregroundColor(Color.black.opacity(0.80))
            .frame(maxWidth: .infinity)
            .background(((isSelected && !typingInAskBar)) ? Color.blue.opacity(0.1) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
        .cornerRadius(5)
        .padding(.top, 14.25)
//        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .onChange(of: typingInAskBar) { isTyping in
            print("Typing in ask bar changed: \(isTyping)") // Debug
            if isTyping && !isArrowKeyUsed {
                selectedIndex = -1
                isHovered = false
                isArrowKeyUsed = false
            }
        }
        .onChange(of: isHovered) { hover in
            print("Hover state changed: \(hover)") // Debug
            if !hover && !isArrowKeyUsed {
                selectedIndex = -1
                isHovered = false
                isArrowKeyUsed = false
            }
        }
        .onHover { hovering in
            print("Hover detected: \(hovering)") // Debug
            isHovered = hovering
            if hovering {
                typingInAskBar = false
                isArrowKeyUsed = false
                selectedIndex = index
            }
        }
    }
    
    private func iconForSuggestionType(_ type: SuggestionType) -> String {
        switch type {
        case .search:
            return "magnifyingglass"
        case .url:
            return "globe"
        case .tab:
            return "rectangle.stack"
        }
    }
    
    private func displayTextForSuggestion(_ suggestion: SuggestionItem) -> String {
        switch suggestion.type {
        case .url:
            return String(suggestion.text.dropFirst(8)).trimmingCharacters(in: ["/"])
        case .tab:
            return "\(suggestion.text)"
        default:
            return suggestion.text
        }
    }
}
