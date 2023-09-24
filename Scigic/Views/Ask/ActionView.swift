
//  Created by Nidhish Gajjar on 2023-06-11.
//


import SwiftUI

struct ActionView: View {
    @EnvironmentObject var commonContext: ContextViewModel
    @EnvironmentObject var slateManager: SlateManagerViewModel
    // Separate data for each row
    let rowOneButtons = [
        "Tell me a bedtime story",
        "Tell me about some popular tourist destinations in Europe.",
        "Compose an email requesting a meeting.",
        "Can you guide me on how to invest in stocks?",
    ]
    
    let rowTwoButtons = [
        "What are some easy dinner recipes for busy weeknights?",
        "Share some tips for maintaining a healthy lifestyle.",
        "What are some fun indoor activities for kids?",
        "Can you explain the effects of climate change?"
    ]
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 20) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(rowOneButtons, id: \.self) { label in
                        Button(action: {
                            self.slateManager.addNewSlate(humanAGIRequest: label, unstated: false)
                            commonContext.isAskViewActive = false
                        }) {
                            Text(label)
                                .padding(.horizontal)
                                .padding(.vertical, 7)
                                .background(
                                    VisualBlurEffect(material: .fullScreenUI) // Change the material here
                                        .overlay(
                                            Rectangle()
                                                .fill(colorScheme == .dark ? .black.opacity(0.05) : .white.opacity(0.8))
                                        )
                                )
                                .foregroundColor(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.5))
                                .cornerRadius(5)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
//                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(rowTwoButtons, id: \.self) { label in
                        Button(action: {
                            self.slateManager.addNewSlate(humanAGIRequest: label, unstated: false)
                            commonContext.isAskViewActive = false
                        }) {
                            Text(label)
                                .padding(.horizontal)
                                .padding(.vertical, 7)
                                .background(
                                    VisualBlurEffect(material: .fullScreenUI) // Change the material here
                                        .overlay(
                                            Rectangle()
                                                .fill(colorScheme == .dark ? .black.opacity(0.05) : .white.opacity(0.8))
                                        )
                                )
                                .foregroundColor(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.5))
                                .cornerRadius(5)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
//                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
    }
}
