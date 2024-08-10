//
//  SuggestionItemView.swift
//  Scigic
//
//  Created by Nidhish Gajjar on 2023-08-16.
//

import SwiftUI

struct SuggestionItemView: View {
    let suggestion: String
    let isSelected: Bool
    let index: Int
    let action: () -> Void
    @Binding var selectedIndex: Int
    @Binding var typingInAskBar: Bool
    @Binding var isHovered: Bool
    @Binding var isArrowKeyUsed: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                HStack(spacing: 5) {
                    // Choose the appropriate icon based on the suggestion's prefix.
                    Image(systemName: suggestion.hasPrefix("https://") ? "globe" : "magnifyingglass")
                        .foregroundColor(.gray)

                    // Extract the display text for the suggestion.
                    let displayText: String = suggestion.hasPrefix("https://")
                        ? String(suggestion.dropFirst(8)).trimmingCharacters(in: ["/"])
                        : suggestion
                    
                    Text(displayText)
                        .lineSpacing(5)
                        .kerning(0.75)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 5)
                        .foregroundColor(colorScheme == .dark ? Color.secondary : Color.primary)
                }


            }
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 7, trailing: 0))
            .foregroundColor(Color.black.opacity(0.80))
            .frame(maxWidth: .infinity)
            .background(((isSelected && !typingInAskBar)) ? Color.blue.opacity(0.1) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
        .cornerRadius(5)
        .padding(.vertical, 5)
        .onChange(of: typingInAskBar) { isTyping in
            if isTyping && !isArrowKeyUsed {
                selectedIndex = -1
                isHovered = false
                isArrowKeyUsed = false
            }
        }
        .onChange(of: isHovered) { hover in
            if !hover && !isArrowKeyUsed {
                selectedIndex = -1
                isHovered = false
                isArrowKeyUsed = false
            }
        }
        .onHover { hovering in
            isHovered = hovering
            if hovering {
                typingInAskBar = false
                isArrowKeyUsed = false
                selectedIndex = index
            }
        }
    }
}

