
//  Created by Nidhish Gajjar on 2023-06-11.
//

import SwiftUI

struct ClipsView: View {
    @EnvironmentObject var commonContext: ContextViewModel
    @EnvironmentObject var slateManager: SlateManagerViewModel
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            ForEach(0..<2) { rowIndex in
                HStack (spacing: 50) {
                    ForEach(0..<5) { columnIndex in
                        let index = rowIndex * 5 + columnIndex
                        Button(action: {
                            if index < commonContext.clips.count {
                                let clip = commonContext.clips[index]
                                commonContext.askTextFromPalette = ""
                                slateManager.addNewSlate(url: clip.url)
                            }
                        }) {
                            Rectangle()
                                .background(
                                    VisualBlurEffect(material: .fullScreenUI) // Change the material here
                                        .overlay(
                                            Rectangle()
                                                .fill(colorScheme == .dark ? .black.opacity(0.05) : .white.opacity(0.8))
                                        )
                                )
                                .foregroundColor(colorScheme == .dark ? .black.opacity(0.05) : .white.opacity(0.8))
                                .frame(width: 70, height: 70)
                                .cornerRadius(20)
                                .overlay(
                                    Text(commonContext.clips[index].name)
                                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.3))
                                        .multilineTextAlignment(.center)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding()
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
    }
}
